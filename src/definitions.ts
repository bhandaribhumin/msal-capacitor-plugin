import '@capacitor/core';

declare module '@capacitor/core' {
  interface PluginRegistry {
    msalPlugin: {};
  }
}

export default {};
