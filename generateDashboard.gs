/**
 * Generates a DASHBOARD sheet with one line chart per exercise showing top set weight over time,
 * using only the dates where that exercise occurs.
 */
function generateDashboard() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const parsed = ss.getSheetByName('PARSED');
  if (!parsed) throw new Error("Sheet named 'PARSED' not found");

  // Get or create the DASHBOARD sheet
  let dash = ss.getSheetByName('DASHBOARD');
  if (!dash) dash = ss.insertSheet('DASHBOARD');
  else dash.clear();

  // Read all parsed data (skip header)
  const allData = parsed.getDataRange().getValues();
  allData.shift(); // remove header row

  // Extract unique exercise names
  const exerciseSet = new Set(allData.map(r => r[1]));
  const exercises = Array.from(exerciseSet);

  let startRow = 1;
  exercises.forEach(exercise => {
    // Filter rows for this exercise
    const rows = allData.filter(r => r[1] === exercise);
    if (rows.length === 0) return;

    // Create table header for this exercise
    dash.getRange(startRow, 1).setValue(exercise);
    dash.getRange(startRow + 1, 1, 1, 2).setValues([['Date', 'Top Weight']]);

    // Compute top weight per date
    const dateWeightMap = {};
    rows.forEach(r => {
      const date = r[0]; // Date object or string
      const weight = Number(r[4]); // Weight column
      if (!isNaN(weight)) {
        dateWeightMap[date] = dateWeightMap[date] !== undefined
          ? Math.max(dateWeightMap[date], weight)
          : weight;
      }
    });

    // Sort dates ascending
    const sortedDates = Object.keys(dateWeightMap).sort((a, b) => new Date(a) - new Date(b));

    // Build data table for sheet
    const table = sortedDates.map(d => [new Date(d), dateWeightMap[d]]);
    dash.getRange(startRow + 2, 1, table.length, 2).setValues(table);

    // Create line chart for this exercise
    const chart = dash.newChart()
      .setChartType(Charts.ChartType.LINE)
      .addRange(dash.getRange(startRow + 2, 1, table.length, 2))
      .setPosition(startRow + 1, 4, 0, 0)
      .setOption('title', exercise + ' - Top Set Weight Over Time')
      .setOption('legend', { position: 'none' })
      .build();
    dash.insertChart(chart);

    // Advance the startRow for next exercise (header + title + data + space)
    startRow += table.length + 4;
  });
}
