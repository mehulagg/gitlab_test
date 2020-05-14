export default {
  /**
   * Convert GraphQL id to database id
   * Examples:
   *
   *   convertGqId("gid://gitlab/Project/8") //=> 8
   *   convertGqId("gid://gitlab/Vulnerability/52") //=> 52
   */
  convertGqId(id) {
    return parseInt(id.split('/').splice(-1), 10);
  },
};
