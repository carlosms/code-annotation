/*
Sample DB for the import command. You can create an sqlite DB with the command:

$ sqlite3 sample.db < sample.sql
*/
CREATE TABLE files (name_a TEXT, name_b TEXT, content_a TEXT, content_b TEXT);

INSERT INTO files values ('project/src/a', 'other_project/src/b',
'Some text',
'Some text
');

INSERT INTO files values (
  'dashboard/src/services/api.js@v0.4.1', 'dashboard/src/services/api.js@v0.1.0',

'import log from ''./log'';

const defaultServerUrl =
  process.env.REACT_APP_SERVER_URL || ''http://0.0.0.0:9999/api'';

const apiUrl = url => `${defaultServerUrl}${url}`;

const unexpectedErrorMsg =
  ''Unexpected error contacting babelfish server. Please, try again.'';

export function parse(language, filename, code, query, serverUrl) {
  return new Promise((resolve, reject) => {
    return fetch(apiUrl(''/parse''), {
      method: ''POST'',
      headers: {
        ''Content-Type'': ''application/json'',
      },
      body: JSON.stringify({
        server_url: serverUrl,
        language,
        filename,
        content: code,
        query,
      }),
    })
      .then(resp => resp.json())
      .then(({ status, errors, uast, language }) => {
        if (status === 0) {
          resolve({ uast, language });
        } else {
          reject(errors ? errors.map(normalizeError) : [''unexpected error'']);
        }
      })
      .catch(err => {
        log.error(err);
        reject([unexpectedErrorMsg]);
      });
  });
}

export function listDrivers() {
  return fetch(apiUrl(''/drivers''))
    .then(checkStatus)
    .then(resp => resp.json());
}

function checkStatus(resp) {
  if (resp.status < 200 || resp.status >= 300) {
    const error = new Error(resp.statusText);
    error.response = resp;
    throw error;
  }
  return resp;
}

function normalizeError(err) {
  if (typeof err === ''object'' && err.hasOwnProperty(''message'')) {
    return err.message;
  } else if (typeof err === ''string'') {
    return err;
  }

  return null;
}

export function getGist(gist) {
  return new Promise((resolve, reject) => {
    return fetch(apiUrl(''/gist?url='' + gist), {
      method: ''GET'',
      headers: {
        ''Content-Type'': ''application/json'',
      },
    })
      .then(checkStatus)
      .then(resp => resp.text())
      .then(code => resolve(code))
      .catch(err => {
        log.error(err);
        reject([err].map(normalizeError));
      });
  });
}

export function version(serverUrl) {
  return fetch(apiUrl(`/version`), {
    method: ''POST'',
    headers: {
      ''Content-Type'': ''application/json'',
    },
    body: JSON.stringify({
      server_url: serverUrl,
    }),
  })
    .then(checkStatus)
    .then(resp => resp.json())
    .catch(err => {
      log.error(err);
      return Promise.reject([err].map(normalizeError));
    });
}',

'const defaultServerUrl =
  process.env.REACT_APP_SERVER_URL || ''http://0.0.0.0:9999/api'';

const apiUrl = url => `${defaultServerUrl}${url}`;

const unexpectedErrorMsg =
  ''Unexpected error contacting babelfish server. Please, try again.'';

export function parse(language, code, serverUrl) {
  return new Promise((resolve, reject) => {
    return fetch(apiUrl(''/parse''), {
      method: ''POST'',
      headers: {
        ''Content-Type'': ''application/json''
      },
      body: JSON.stringify({
        server_url: serverUrl,
        language,
        content: code
      })
    })
      .then(resp => resp.json())
      .then(({ status, errors, uast }) => {
        if (status === ''ok'') {
          resolve(uast);
        } else {
          reject(errors.map(normalizeError));
        }
      })
      .catch(err => {
        console.error(err);
        reject([unexpectedErrorMsg]);
      });
  });
}

export function listDrivers() {
  return fetch(apiUrl(''/drivers'')).then(checkStatus).then(resp => resp.json());
}

function checkStatus(resp) {
  if (resp.status < 200 || resp.status >= 300) {
    const error = new Error(resp.statusText);
    error.response = resp;
    throw error;
  }
  return resp;
}

function normalizeError(err) {
  if (typeof err === ''object'' && err.hasOwnProperty(''message'')) {
    return err.message;
  } else if (typeof err === ''string'') {
    return err;
  }

  return null;
}');

INSERT INTO files VALUES (
  'dashboard/src/components/Header.js@v0.4.1', 'dashboard/src/components/Header.js@v0.3.0',

'import React, { Component } from ''react'';
import styled, { css } from ''styled-components'';
import CopyToClipboard from ''react-copy-to-clipboard'';
import { shadow, font, background, border } from ''../styling/variables'';
import Button, { CssButton } from ''./Button'';
import { connect } from ''react-redux'';
import log from ''../services/log'';
import {
  select as languageSelect,
  set as languageSet,
} from ''../state/languages'';
import {
  examples as examplesList,
  select as exampleSelect,
} from ''../state/examples'';
import { runParser } from ''../state/code'';
import { setURL as gistSetURL, load as gistLoad } from ''../state/gist'';
import { isUrl } from ''../state/options'';

import bblfshLogo from ''../img/babelfish_logo.svg'';
import githubIcon from ''../img/github.svg'';

const Container = styled.header`
  height: 70px;
  padding: 0 1rem;
  display: flex;
  align-items: center;
  background: ${background.light};
  border-bottom: 1px solid ${border.smooth};
  z-index: 9999;
  box-shadow: 0 5px 25px ${shadow.topbar};
`;

const Title = styled.h1`
  display: flex;
  align-items: center;
  font-size: 1.5rem;
  font-weight: normal;
  padding: 0;
  margin: 0;
  height: 100%;
  border-right: 1px solid ${border.smooth};
  padding-right: 1rem;
`;

const TitleImage = styled.img`
  height: 40px;
`;

const DashboardTitle = styled.span`
  margin-left: 0.8rem;
`;

const Actions = styled.div`
  width: 100%;
  display: flex;
  margin-left: 1rem;
  height: 100%;
`;

const Label = styled.label`
  color: grey;
  margin-right: 1em;
  font-size: 0.8rem;
  font-weight: bold;
  text-transform: uppercase;
  color: #636262;
`;

const InputGroup = styled.div`
  display: flex;
  align-items: center;
  height: 100%;
  border-right: 1px solid ${border.smooth};
  padding-right: 1rem;

  & + & {
    margin-left: 1rem;
  }

  &:last-child {
    border-right: none;
  }
`;

const InputGroupRight = InputGroup.extend`
  flex-grow: 1;
  flex-direction: row-reverse;
  padding-right: 0;
`;

const CssInput = css`
  border-radius: 3px;
  border: 1px solid ${border.smooth};
  background: white;
  padding: 0.5em 0.5em;
  text-transform: uppercase;
  font-weight: bold;
  font-size: 0.8rem;

  & + button {
    margin-left: 3px;
  }
`;

const Select = styled.select`
  ${CssInput} font-size: .7rem;
  text-transform: uppercase;
`;

const Input = styled.input`
  ${CssInput} text-transform: none;
`;

const RunButton = styled.button`
  ${CssButton} padding: .7rem 1.8rem;
  background: ${background.accent};
  color: ${font.color.white};
  white-space: nowrap;

  &:hover {
    box-shadow: 0 5px 15px ${shadow.primaryButton};
  }
`;

const DriverCodeBox = styled.div`
  display: flex;
  align-items: center;
  margin-left: 0.5rem;
`;

const DriverCodeIcon = styled.img`
  width: 20px;
  opacity: 0.7;
  margin-right: 0.3rem;
`;

const DriverCodeLink = styled.a`
  display: flex;
  align-items: center;
  color: black;
  text-decoration: none;
  font-size: 0.9rem;

  &:hover {
    color: ${font.color.accentDark};
  }

  &:hover ${DriverCodeIcon} {
    opacity: 1;
  }
`;

export function DriverCode({ languages, selectedLanguage, actualLanguage }) {
  const driver = selectedLanguage === '''' ? actualLanguage : selectedLanguage;

  return (
    <DriverCodeBox>
      <DriverCodeLink
        href={languages[driver] && languages[driver].url}
        target="_blank"
      >
        <DriverCodeIcon
          src={githubIcon}
          alt="Driver code repository on GitHub"
          title="Driver code repository on GitHub"
        />
      </DriverCodeLink>
    </DriverCodeBox>
  );
}

export class Header extends Component {
  onShareGist(shared) {
    log.info(''shared url:'' + shared);
  }

  getSharableUrl() {
    return `${window.location.origin}/${this.props.gist}`;
  }

  render() {
    const {
      selectedLanguage,
      actualLanguage,
      languages,
      examples,
      onLanguageChanged,
      onExampleChanged,
      onRunParser,
      parsing,
      selectedExample,
      canParse,
      gistURL,
      isValidGist,
      updateGistUrl,
      onTryLoadingGist,
    } = this.props;

    const languageOptions = Object.keys(languages).map(k => {
      let name = languages[k].name;
      if (
        k === '''' &&
        !selectedLanguage &&
        actualLanguage &&
        languages[actualLanguage]
      ) {
        name = `${languages[actualLanguage].name} (auto)`;
      }

      return (
        <option value={k} key={k}>
          {name}
        </option>
      );
    });

    const examplesOptions = [
      <option value="" key="">
        ---
      </option>,
      Object.keys(examples).map((key, k) => (
        <option value={key} key={k}>
          {examples[key].name}
        </option>
      )),
    ];

    return (
      <Container>
        <Title>
          <TitleImage src={bblfshLogo} alt="bblfsh" />
          <DashboardTitle>Dashboard</DashboardTitle>
        </Title>

        <Actions>
          <InputGroup>
            <Label htmlFor="language-selector">Language</Label>
            <Select
              id="language-selector"
              onChange={e => onLanguageChanged(e.target.value)}
              value={selectedLanguage}
            >
              {languageOptions}
            </Select>

            <DriverCode
              languages={languages}
              selectedLanguage={selectedLanguage}
              actualLanguage={actualLanguage}
            />
          </InputGroup>

          <InputGroup>
            <Label htmlFor="examples-selector">Examples</Label>
            <Select
              id="examples-selector"
              onChange={e => onExampleChanged(e.target.value)}
              value={selectedExample}
            >
              {examplesOptions}
            </Select>
          </InputGroup>

          <InputGroup>
            <Input
              type="url"
              value={gistURL}
              onChange={e => updateGistUrl(e.target.value)}
              placeholder="raw gist url"
            />
            <Button onClick={onTryLoadingGist} disabled={!isValidGist}>
              load
            </Button>
            <CopyToClipboard
              text={this.getSharableUrl()}
              onCopy={shared => this.onShareGist(shared)}
            >
              <Button disabled={!isValidGist}>share</Button>
            </CopyToClipboard>
          </InputGroup>

          <InputGroupRight>
            <RunButton
              id="run-parser"
              onClick={onRunParser}
              disabled={!canParse}
            >
              {parsing ? ''Parsing...'' : ''Run parser''}
            </RunButton>
          </InputGroupRight>
        </Actions>
      </Container>
    );
  }
}

export const mapStateToProps = state => {
  const { languages, examples, options, code, gist } = state;
  const validServerUrl = isUrl(options.customServerUrl);

  return {
    languages: languages.languages,
    selectedLanguage: languages.selected,
    actualLanguage: languages.actual,

    selectedExample: examples.selected,
    examples: examplesList,

    parsing: code.parsing,
    canParse:
      !languages.loading &&
      !code.parsing &&
      (validServerUrl || !options.customServer) &&
      !!code.code,

    gistURL: gist.url,
    gist: gist.gist,
    isValidGist: gist.isValid,
  };
};

const mapDispatchToProps = dispatch => {
  return {
    onLanguageChanged: lang => {
      dispatch(languageSelect(lang));
    },
    onExampleChanged: key => {
      dispatch(exampleSelect(key));
      dispatch(runParser());
    },
    onRunParser: () => dispatch(runParser()),
    updateGistUrl: url => dispatch(gistSetURL(url)),
    onTryLoadingGist: () => {
      dispatch(gistLoad())
        .then(() => {
          // reset selected language to allow babelfish server recognize it
          dispatch(languageSet(''''));
          dispatch(languageSelect(''''));
          dispatch(runParser());
        })
        .catch(() => log.error(''can not load gist''));
    },
  };
};

export default connect(mapStateToProps, mapDispatchToProps)(Header);',
'import React from ''react'';
import styled from ''styled-components'';
import { shadow, font, background, border } from ''../styling/variables'';

import bblfshLogo from ''../img/babelfish_logo.svg'';
import githubIcon from ''../img/github.svg'';

const Container = styled.header`
  height: 70px;
  padding: 0 1rem;
  display: flex;
  align-items: center;
  background: ${background.light};
  border-bottom: 1px solid ${border.smooth};
  z-index: 9999;
  box-shadow: 0 5px 25px ${shadow.topbar};
`;

const Title = styled.h1`
  display: flex;
  align-items: center;
  font-size: 1.5rem;
  font-weight: normal;
  padding: 0;
  margin: 0;
  height: 100%;
  border-right: 1px solid ${border.smooth};
  padding-right: 1rem;
`;

const TitleImage = styled.img`height: 40px;`;

const DashboardTitle = styled.span`margin-left: .8rem;`;

const Actions = styled.div`
  width: 100%;
  display: flex;
  margin-left: 1rem;
  height: 100%;
`;

const Label = styled.label`
  color: grey;
  margin-right: 1em;
  font-size: .8rem;
  font-weight: bold;
  text-transform: uppercase;
  color: #636262;
`;

const InputGroup = styled.div`
  display: flex;
  align-items: center;
  height: 100%;
  border-right: 1px solid ${border.smooth};
  padding-right: 1rem;

  & + & {
    margin-left: 1rem;
  }

  &:last-child {
    border-right: none;
  }
`;

const InputGroupRight = InputGroup.extend`
  flex-grow: 1;
  flex-direction: row-reverse;
  padding-right: 0;
`

const Select = styled.select`
  border-radius: 3px;
  border: 1px solid ${border.smooth};
  background: white;
  padding: .5em .5em;
  text-transform: uppercase;
  font-weight: bold;
  font-size: .7rem;
`;

const RunButton = styled.button`
  padding: .7rem 1.8rem;
  border-radius: 3px;
  border: none;
  cursor: pointer;
  background: ${background.accent};
  color: white;
  font-weight: bold;
  text-transform: uppercase;
  font-size: .8rem;
  letter-spacing: .05em;
  transition: box-shadow 300ms ease-in-out;

  &[disabled] {
    opacity: .6;
    pointer-events: none;
  }

  &:hover {
    box-shadow: 0 5px 15px ${shadow.primaryButton};
  }
`;

const DriverCodeBox = styled.div`
  display: flex;
  align-items: center;
  margin-left: .5rem;
`;

const DriverCodeIcon = styled.img`
  width: 20px;
  opacity: .7;
  margin-right: .3rem;
`;

const DriverCodeLink = styled.a`
  display: flex;
  align-items: center;
  color: black;
  text-decoration: none;
  font-size: .9rem;

  &:hover {
    color: ${font.color.accentDark};
  }

  &:hover ${DriverCodeIcon} {
    opacity: 1;
  }
`;

export function DriverCode({ languages, selectedLanguage, actualLanguage }) {
  const driver =
    selectedLanguage === ''auto'' ? actualLanguage : selectedLanguage;

  return (
    <DriverCodeBox>
      <DriverCodeLink
        href={languages[driver] && languages[driver].url}
        target="_blank"
      >
        <DriverCodeIcon src={githubIcon}
          alt="Driver code repository on GitHub"
          title="Driver code repository on GitHub"
        />
      </DriverCodeLink>
    </DriverCodeBox>
  );
}

export default function Header({
  selectedLanguage,
  languages,
  examples,
  onLanguageChanged,
  onExampleChanged,
  onRunParser,
  loading,
  actualLanguage,
  selectedExample,
  canParse
}) {
  const languageOptions = Object.keys(languages).map(k => {
    let name = ''(auto)'';
    if (k === ''auto'' && languages[actualLanguage]) {
      name = `${languages[actualLanguage].name} ${name}`;
    } else if (languages[k] && k !== ''auto'') {
      name = languages[k].name;
    }

    return (
      <option value={k} key={k}>
        {name}
      </option>
    );
  });

  const examplesOptions = Object.keys(examples).map((key, k) =>
    <option value={key} key={k}>
      {examples[key].name}
    </option>
  );

  return (
    <Container>
      <Title>
        <TitleImage src={bblfshLogo} alt="bblfsh" />
        <DashboardTitle>Dashboard</DashboardTitle>
      </Title>

      <Actions>
        <InputGroup>
          <Label htmlFor="language-selector">Language</Label>
          <Select
            id="language-selector"
            onChange={onLanguageChanged}
            value={selectedLanguage}
          >
            {languageOptions}
          </Select>

          <DriverCode
            languages={languages}
            selectedLanguage={selectedLanguage}
            actualLanguage={actualLanguage}
          />
        </InputGroup>

        <InputGroup>
          <Label htmlFor="examples-selector">Examples</Label>
          <Select
            id="examples-selector"
            onChange={onExampleChanged}
            value={selectedExample}
          >
            {examplesOptions}
          </Select>
        </InputGroup>

        <InputGroupRight>
          <RunButton id="run-parser" onClick={onRunParser} disabled={!canParse}>
            {loading ? ''Parsing...'' : ''Run parser''}
          </RunButton>
        </InputGroupRight>
      </Actions>
    </Container>
  );
}');
