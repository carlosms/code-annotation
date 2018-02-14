import React, { Component } from 'react';
import { Fragment } from 'redux-little-router';
import { Helmet } from 'react-helmet';
import { namedRoutes } from './state/routes';
import Errors from './components/Errors';
import Index from './pages/Index';
import Experiment from './pages/Experiment';
import Final from './pages/Final';
import Review from './pages/Review';

class App extends Component {
  render() {
    return (
      <Fragment forRoute="/">
        <div style={{ height: '100%' }}>
          <Helmet titleTemplate="%s | source{d} Code Annotation Tool" />
          <Errors />
          <Fragment forRoute={namedRoutes.index}>
            <Index />
          </Fragment>
          <Fragment forRoute={namedRoutes.finish}>
            <Final />
          </Fragment>
          <Fragment forRoute={namedRoutes.question}>
            <Experiment />
          </Fragment>
          <Fragment forRoute={namedRoutes.experiment}>
            <Experiment />
          </Fragment>
          <Fragment forRoute={namedRoutes.review}>
            <Review />
          </Fragment>
          <Fragment forNoMatch>
            <div>not found</div>
          </Fragment>
        </div>
      </Fragment>
    );
  }
}

export default App;
