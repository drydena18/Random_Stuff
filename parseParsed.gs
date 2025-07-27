/**
 * Reads LINES! and builds PARSED! with Date, Exercise, Set, Reps, Weight, Volume, ORM.
 * ORM is estimated 1RM using the Epley formula: weight * (1 + reps/30).
 */
function parseParsed() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const linesSheet = ss.getSheetByName('LINES');
  if (!linesSheet) throw new Error("Sheet named 'LINES' not found");
  
  // Get or create the PARSED sheet
  let parsed = ss.getSheetByName('PARSED');
  if (!parsed) parsed = ss.insertSheet('PARSED');
  parsed.clearContents();
  // Add ORM column header
  parsed.appendRow(['Date','Exercise','Set','Reps','Weight','Volume','ORM']);
  
  // Read all LINES rows (skip header)
  const data = linesSheet.getRange(2, 1, linesSheet.getLastRow() - 1, 2).getValues();
  data.forEach(row => {
    const [date, line] = row;
    if (!date || !line) return;
    
    // Extract exercise name before the dash
    const dashIndex = line.indexOf(' - ');
    const exName = dashIndex > -1 ? line.substring(0, dashIndex).trim() : line.trim();
    
    // Extract everything inside the last parentheses as the sets chunk
    const parenMatch = line.match(/\(([^)]+)\)\s*$/);
    const setsChunk = parenMatch ? parenMatch[1] : line.substring(dashIndex + 3);
    
    // Split into individual sets
    const sets = setsChunk.split(',').map(s => s.trim()).filter(s => s);
    sets.forEach((chunk, i) => {
      const repMatch = chunk.match(/x(\d+)/);
      const weightMatch = chunk.match(/^(\d+(\.\d+)?)/);
      const reps = repMatch   ? parseInt(repMatch[1], 10)   : '';
      const weight = weightMatch ? parseFloat(weightMatch[1]) : 'BW';
      const volume = (weight === 'BW' || reps === '') ? '' : weight * reps;
      // Epley 1RM estimate
      const orm = (weight === 'BW' || reps === '') 
        ? '' 
        : +(weight * (1 + reps/30)).toFixed(2);
      
      parsed.appendRow([date, exName, i + 1, reps, weight, volume, orm]);
    });
  });
}
