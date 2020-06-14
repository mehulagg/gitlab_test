import eventHub from '../../eventhub';
import Disposable from './disposable';
import Model from './model';

export default class ModelManager {
  constructor() {
    this.disposable = new Disposable();
    this.models = new Map();
  }

  hasCachedModel(key) {
    return this.models.has(key);
  }

  getModel(key) {
    return this.models.get(key);
  }

  addModel(file, head = null) {
    if (this.hasCachedModel(file.path)) {
      return this.getModel(file.path);
    }

    const model = new Model(file, head);
    this.models.set(model.path, model);
    this.disposable.add(model);

    eventHub.$on(
      `editor.update.model.dispose.${file.path}`,
      this.removeCachedModel.bind(this, file),
    );

    return model;
  }

  removeCachedModel(file) {
    this.models.delete(file.path);

    eventHub.$off(`editor.update.model.dispose.${file.path}`, this.removeCachedModel);
  }

  dispose() {
    // dispose of all the models
    this.disposable.dispose();
    this.models.clear();
  }
}
