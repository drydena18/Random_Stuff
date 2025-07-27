function parseWorkoutLogs() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const raw = ss.getSheetByName('RAW');
  if (!raw) throw new Error("Sheet named 'RAW' not found");
  
  // Get or create the LINES sheet
  let lines = ss.getSheetByName('LINES');
  if (!lines) lines = ss.insertSheet('LINES');
  lines.clearContents();
  lines.appendRow(['Date', 'Exercise']);
  
  // Read all RAW rows (skip header)
  const rawData = raw.getRange(2, 1, raw.getLastRow() - 1, 2).getValues();
  rawData.forEach(row => {
    const [date, log] = row;
    if (date && log) {
      // Split on line breaks
      log.toString().split('\n').forEach(line => {
        line = line.trim();
        if (line) {
          lines.appendRow([date, line]);
        }
      });
    }
  });
}
