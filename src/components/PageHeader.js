import React from 'react';
import { Navbar, Nav, NavItem, Row, Col } from 'react-bootstrap';

function PageHeader({ username, avatarUrl }) {
  return (
    <Row>
      <Col xs={12}>
        <Navbar fluid>
          <Navbar.Header>
            <Navbar.Brand>
              <a href="/">source{'{d}'} code annotation</a>
            </Navbar.Brand>
          </Navbar.Header>
          <Nav pullRight>
            <NavItem eventKey={1} href="/">
              dashboard
            </NavItem>
            <NavItem eventKey={2}>
              <img
                src={avatarUrl}
                alt={username}
                style={{ width: '24px', height: '24px', margin: '-3px 0' }}
              />
            </NavItem>
          </Nav>
        </Navbar>
      </Col>
    </Row>
  );
}

export default PageHeader;
