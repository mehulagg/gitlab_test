<script>
import { ROLLOUT_STRATEGY_ALL_USERS } from '../../constants';
import { strategyComponent } from '../../utils';

export default {
  mixins: [
    strategyComponent(strategy => ({
      ...strategy,
      name: ROLLOUT_STRATEGY_ALL_USERS,
      parameters: {},
    })),
  ],
  mounted() {
    this.onParameterChange();
  },
  render() {
    return this.$slots.default;
  },
};
</script>
