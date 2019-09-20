import _ from 'underscore';

/**
 * Adds the line number property
 * @param Object line
 * @param Number lineNumber
 */
export const parseLine = (line = {}, lineNumber) => ({
  ...line,
  lineNumber,
});
/**
 * When a line has `section_header` set to true, we create a new
 * structure to allow to nest the lines that belong to the
 * collpasible section
 *
 * @param Object line
 * @param Number lineNumber
 */
export const parseHeaderLine = (line = {}, lineNumber) => ({
  isClosed: true,
  isHeader: true,
  line: parseLine(line, lineNumber),
  lines: [],
});


/**
 * Some `section_duration` information are sent in the end
 * of the sections.
 *
 * This function finds the section it belongs too and adds it to the correct
 * object
 *
 * @param Array data
 * @param Object durationLine
 */
export const addDurationToHeader = (data, durationLine) => {
  data.find(el => {
    if (el.line && el.line.section === durationLine.section) {
      el.line.section_duration = durationLine.section_duration;
    }
  });
};

/**
 * Parses the job log content into a structure usable by the template
 *
 * For collaspible lines (section_header = true):
 *    - creates a new array to hold the lines that are collpasible,
 *    - adds a isClosed property to handle toggle
 *    - adds a isHeader property to handle template logic
 *    - adds the section_duration
 * For each line:
 *    - adds the index as  lineNumber
 *
 * @param {Array} lines
 * @returns {Array}
 */
export const logLinesParser = (lines = [], lineNumberStart, accumulator = []) =>
  lines.reduce((acc, line, index) => {
    const lineNumber = lineNumberStart ? lineNumberStart + index : index;
    const last = acc[acc.length - 1];

    if (line.section_header) {
      acc.push(parseHeaderLine(line, lineNumber));
    } else if (last && last.isHeader && !line.section_duration) {
      last.lines.push(parseLine(line, lineNumber));
    } else if (line.section_duration) {
      addDurationToHeader(acc, line);
    } else {
      acc.push(parseLine(line, lineNumber));
    }

    return acc;
  }, accumulator);

export const updateIncrementalTrace = (newLog, oldParsed = []) => {
  const parsedLog = findOffsetAndRemove(newLog, oldParsed);
  return logLinesParser(newLog, parsedLog.lastLine, parsedLog.log);
};

export const findOffsetAndRemove = (newLog, oldParsed) => {
  const cloneOldLog = [...oldParsed];
  const lastIndex = cloneOldLog.length - 1;
  const last = cloneOldLog[lastIndex];

  const firstNew = newLog[0];

  const parsed = {};

  if (last.line.offset === firstNew.offset) {
    cloneOldLog.splice(lastIndex);
    parsed.lastLine = last.lineNumber;
  } else if (last.lines.length) {
    const lastNestedIndex = last.lines.length - 1;
    const lastNested = last.lines[lastNestedIndex];
    if (lastNested.offset === firstNew.offset) {
      last.lines.splice(lastNestedIndex);
      parsed.lastLine = lastNested.lineNumber;
    }
  }

  parsed.log = cloneOldLog;
  return parsed;
};

export const isNewJobLogActive = () => gon && gon.features && gon.features.jobLogJson;
