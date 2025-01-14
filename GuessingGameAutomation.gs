function onEdit(e) {
  const sheet = e.source.getSheetByName("Guesses");
  const editedRange = e.range;

  // Check if the edit was made in the 'Guesses' sheet in relevant columns
  if (sheet.getName() === "Guesses" && editedRange.getColumn() === 2) {
    updateFrequencyTable(); // Call function to update frequency table and chart
  }
}

function updateFrequencyTable() {
  const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  const guessesSheetName = "Guesses";
  const ftSheetName = "FT";

  const guessesSheet = spreadsheet.getSheetByName(guessesSheetName);
  const ftSheet = spreadsheet.getSheetByName(ftSheetName);

  if (!guessesSheet || !ftSheet) {
    Logger.log("One or both sheets are missing.");
    return;
  }

  // Get all data from the Guesses sheet
  const data = guessesSheet.getDataRange().getValues(); // Includes header row
  if (data.length <= 1) {
    Logger.log("No data found in the Guesses sheet.");
    ftSheet.clear(); // Clear FT sheet if no guesses exist
    return;
  }

  // Prepare to track duplicates
  const studentGuesses = {};
  const updatedStatus = [];

  // Process each row to check for duplicates and valid guesses
  const validGuesses = data.slice(1).map((row, index) => {
    const name = row[0];
    const guess = row[1];
    const status = row[2];

    if (guess === "" || isNaN(guess)) {
      updatedStatus.push(["Invalid"]);
      return null;
    }

    // Check for duplicates based on the student's name and guess
    const key = `${name}-${guess}`;
    if (studentGuesses[key]) {
      updatedStatus.push(["Duplicate"]);
      return null;
    }

    studentGuesses[key] = true;
    updatedStatus.push(["Valid"]);
    return Number(guess); // Valid guess
  }).filter(value => value !== null); // Exclude invalid guesses

  // Update the `Status` column in the Guesses sheet
  guessesSheet.getRange(2, 3, updatedStatus.length, 1).setValues(updatedStatus);

  if (validGuesses.length === 0) {
    Logger.log("No valid guesses found.");
    ftSheet.clear(); // Clear FT sheet if no valid guesses exist
    return;
  }

  // Calculate frequencies
  const frequency = validGuesses.reduce((acc, num) => {
    acc[num] = (acc[num] || 0) + 1;
    return acc;
  }, {});

  // Sort guesses numerically
  const sortedGuesses = Object.keys(frequency).map(Number).sort((a, b) => a - b);

  // Prepare data for the frequency table
  const dataTable = sortedGuesses.map(num => [num, frequency[num]]);

  // Clear and write the frequency table to the FT sheet
  ftSheet.clear();
  ftSheet.getRange(1, 1, 1, 2).setValues([["Number", "Frequency"]]); // Headers
  ftSheet.getRange(2, 1, dataTable.length, 2).setValues(dataTable);

  // Create or update the bar graph
  createBarGraph(ftSheet, dataTable.length);
}

function createBarGraph(ftSheet, dataLength) {
  const existingCharts = ftSheet.getCharts();

  // Define the range of the frequency table
  const range = ftSheet.getRange(1, 1, dataLength + 1, 2); // Include headers

  let chart;
  if (existingCharts.length > 0) {
    // Modify the first existing chart if it exists
    chart = existingCharts[0].modify();
  } else {
    // Create a new chart if none exists
    chart = ftSheet.newChart();
  }

  // Configure the bar graph
  chart.setChartType(Charts.ChartType.BAR) // Bar graph
       .addRange(range)
       .setPosition(dataLength + 3, 1, 0, 0) // Place the chart below the table
       .setOption("title", "Guess Distribution")
       .setOption("hAxis", { title: "Frequency", minValue: 0 }) // Horizontal axis: Frequency
       .setOption("vAxis", { title: "Number" }) // Vertical axis: Guess Numbers
       .setOption("legend", { position: "none" });

  // Update or add the chart to the FT sheet
  ftSheet.updateChart(chart.build());
}
