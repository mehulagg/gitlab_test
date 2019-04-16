export default {
  hasProject: state => !!state.selectedProject.projectId,
  hasZone: state => !!state.selectedZone,
  hasMachineType: state => !!state.selectedMachineType,
};
