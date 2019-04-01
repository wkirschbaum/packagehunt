import React, { Component } from "react";
import ReactDOM from "react-dom";
import PropTypes from "prop-types";
import axios from 'axios';

class Home extends React.Component {
    constructor(props) {
        super(props);
        this.state = {packages: []};
        this.handleChange = this.handleChange.bind(this);
    };

    handleChange(term) {
        this.fetchReactions(term);
    };

    fetchReactions(term = "") {
        axios.get('/api/packages?q=' + term)
            .then((response) => {
                this.setState({
                    packages: response.data
                });
            }).catch((error) => {
                console.log(error);
            }).then(() => {
            });
    };

    componentDidMount() {
        this.fetchReactions();
    };

    render() {
        return (
            <div>
              <Search handleChange={this.handleChange} />
              <ListOfPackages packages={this.state.packages} />
            </div>
        );
    };
};

class ListOfPackages extends React.Component {
    render() {
        return (
            <table>
              {this.props.packages.map(p => (
                  <tr key={p.id}>
                    <td>
                      {p.name}
                    </td>
                    <td>
                      {p.version}
                    </td>
                    <td>
                      {p.project_name}
                    </td>
                    <td>
                      {p.language_version}
                    </td>
                  </tr>
              ))}
            </table>
        );
    }
}

class Search extends React.Component {
    constructor(props) {
        super(props);
        this.state = {value: ""};
        this.handleChange = this.handleChange.bind(this);
    }

    handleChange(e) {
        this.props.handleChange(e.target.value);
    }

    render() {
        return (
            <div className="field">
              <input type="text" onChange={this.handleChange} name="search" placeholder="search here..." className="input" />
            </div>
        );
    }
}

document.addEventListener('DOMContentLoaded', () => {
    ReactDOM.render(
        <Home />,
        document.getElementById('app')
    );
});
