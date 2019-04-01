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
        console.log(term);
    };

    fetchReactions(term = "") {
        axios.get('/api/packages?q=' + term)
            .then((response) => {
                this.setState({
                    reactions: response.data
                });
            }).catch((error) => {
                console.log(error);
            }).then(() => {
            });
    }

    render() {
        return (
            <div>
              <div>Hello, you are home now</div>
              <Search handleChange={this.handleChange} />
            </div>
        );
    };
};

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
