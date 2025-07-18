import { render } from 'inferno';

import SCPResearchConsole from './SCPResearchConsole';

const renderApp = () => {
  const app = document.getElementById('app');
  if (app) {
    render(<SCPResearchConsole />, app);
  }
};

renderApp();

if (module.hot) {
  module.hot.accept('./SCPResearchConsole', renderApp);
}
