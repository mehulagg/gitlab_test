export default {
  lines: [
    {
      offset: 0,
      content: [{ text: 'Hello' }],
    },
    {
      offset: 5,
      content: [{ text: 'foo' }],
      sections: ['prepare-script'],
      section_header: true,
    },
    {
      offset: 52,
      content: [{ text: 'bar' }],
      sections: ['prepare-script', 'prepare-script-nested'],
      section_header: true,
      section_duration: "00:02",
    },
    {
      offset: 80,
      content: [{ text: 'this is a collapsible nested section' }],
      sections: ['prepare-script', 'prepare-script-nested'],
    },
    {
      offset: 106,
      content: [],
      sections: ['prepare-script'],
      section_duration: "00:03",
    },
    {
      offset: 155,
      content: [],
    },
  ],
};
