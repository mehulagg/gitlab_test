export default {
  lines: [
    {
      offset: 0,
      content: [{ text: 'Hello' }],
      lineNumber: 0,
    },
    {
      offset: 5,
      section_header: true,
      isHeader: true,
      isClosed: true,
      line: {
        content: [{ text: 'foo' }],
        sections: ['prepare-script'],
        lineNumber: 1,
      },
      section_duration: "00:03",
      lines: [
        {
          section_header: true,
          section_duration: "00:02",
          isHeader: true,
          isClosed: true,
          line: {
            offset: 52,
            content: [{ text: 'bar' }],
            sections: ['prepare-script', 'prepare-script-nested'],
            lineNumber: 2,
          },
          lines: [
            {
              offset: 80,
              content: [{ text: 'this is a collapsible nested section' }],
              sections: ['prepare-script', 'prepare-script-nested'],
              lineNumber: 3.
            }
          ]
        }
      ]
    },
  ],
};
