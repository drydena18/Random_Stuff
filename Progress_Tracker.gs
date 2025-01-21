function updateWeeklyExerciseCharts() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet();
  const days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];
  const rawDataSheetPrefixes = {
    "Monday": "Monday_Upper_Body",
    "Tuesday": "Tuesday_Lower_Body",
    "Wednesday": "Wednesday_Upper_Body",
    "Thursday": "Thursday_Push_Pull",
    "Friday": "Friday_Lower_Core"
  };

  days.forEach(day => {
    const rawDataSheetName = rawDataSheetPrefixes[day];
    const progressSheetName = `${day}_Progress`;

    const rawDataSheet = sheet.getSheetByName(rawDataSheetName);
    if (!rawDataSheet) {
      Logger.log(`Sheet "${rawDataSheetName}" not found.`);
      return;
    }

    const progressSheet = getOrCreateSheet(sheet, progressSheetName);
    progressSheet.clear(); // Clear all data in the progress sheet
    clearAllCharts(progressSheet); // Remove all existing charts

    const rawData = rawDataSheet.getDataRange().getValues();
    const headerRow = rawData[0];
    const dateIndex = headerRow.indexOf("Date");
    const exerciseIndex = headerRow.indexOf("Exercise");
    const repsIndex = headerRow.indexOf("Rep(s)");
    const weightIndex = headerRow.indexOf("Weight (lbs)");

    if ([dateIndex, exerciseIndex, repsIndex, weightIndex].includes(-1)) {
      Logger.log(`Required columns not found in "${rawDataSheetName}". Ensure the columns are named: Date, Exercise, Rep(s), and Weight (lbs).`);
      return;
    }

    // Group data by exercise
    const exerciseData = {};
    rawData.slice(1).forEach(row => {
      const exercise = row[exerciseIndex];
      if (!exercise) return;

      if (!exerciseData[exercise]) {
        exerciseData[exercise] = [];
      }
      exerciseData[exercise].push({
        date: row[dateIndex],
        reps: row[repsIndex],
        weight: row[weightIndex]
      });
    });

    let currentRow = 1; // Start at row 1 for data tables
    const chartStartColumn = 7; // Column G
    const chartHeight = 20; // Vertical spacing for charts

    // Create charts for each exercise
    Object.keys(exerciseData).forEach(exercise => {
      const progressData = [];
      const data = exerciseData[exercise];
      const groupedByDate = {};

      // Group data by date and calculate metrics
      data.forEach(entry => {
        const date = entry.date;
        if (!groupedByDate[date]) {
          groupedByDate[date] = { totalReps: 0, weights: [] };
        }
        groupedByDate[date].totalReps += entry.reps;
        groupedByDate[date].weights.push(entry.weight);
      });

      Object.keys(groupedByDate).forEach(date => {
        const weights = groupedByDate[date].weights;
        const maxWeight = Math.max(...weights);
        const totalReps = groupedByDate[date].totalReps;
        const meanWeight = weights.reduce((sum, weight) => sum + weight, 0) / weights.length;
        const se = Math.sqrt(weights.map(w => Math.pow(w - meanWeight, 2)).reduce((sum, diff) => sum + diff, 0) / (weights.length - 1) || 0);

        progressData.push([date, maxWeight, totalReps, meanWeight, se]);
      });

      // Write data for the exercise into the sheet
      progressSheet.getRange(currentRow, 1, 1, 1).setValue(exercise); // Exercise name
      progressSheet.getRange(currentRow + 1, 1, 1, 5).setValues([["Date", "Max Weight", "Total Reps", "Mean Weight", "SE"]]); // Headers
      progressSheet.getRange(currentRow + 2, 1, progressData.length, 5).setValues(progressData); // Data

      // Add chart for the exercise
      const chart = progressSheet.newChart()
        .setChartType(Charts.ChartType.LINE)
        .addRange(progressSheet.getRange(currentRow + 1, 1, progressData.length + 1, 5))
        .setPosition(currentRow, chartStartColumn, 0, 0) // Start in column G
        .setOption("title", `${exercise} Progress`)
        .setOption("legend", { position: "bottom" })
        .setOption("series", {
          0: { labelInLegend: "Max Weight", color: "green" },
          1: { labelInLegend: "Total Reps", color: "blue" },
          2: { labelInLegend: "Mean Weight", color: "red" },
          3: { labelInLegend: "SE", color: "lightblue" }
        })
        .build();

      progressSheet.insertChart(chart);

      // Update the row position for the next exercise
      currentRow += chartHeight + progressData.length + 3; // 20 rows for chart + data + spacing
    });
  });
}

// Helper function to create or get a sheet
function getOrCreateSheet(spreadsheet, sheetName) {
  let sheet = spreadsheet.getSheetByName(sheetName);
  if (!sheet) {
    sheet = spreadsheet.insertSheet(sheetName);
  }
  return sheet;
}

// Helper function to clear all charts from a sheet
function clearAllCharts(sheet) {
  const charts = sheet.getCharts();
  charts.forEach(chart => {
    sheet.removeChart(chart);
  });
}
