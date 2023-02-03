import React, {useState} from 'react';

import logo from './logo.svg';
import './App.css';

import api from './services/Api';

function App() {
  const [uploaded, setUploaded] = useState(false);

  const handleFileChange = async (e) => {
    if (!e.target.files) {
      return;
    }

    // get the presigned url
    let response = await api.getPresignedUrl();

    if (response.status < 200 && response.status > 300) {
      // show error getting presigned url
      return;
    }

    const file = e.target.files[0];
    const {url} = response.body;

    // uploading the file with put request to the presigned url
    response = await fetch(url, {
      body: file,
      method: "PUT"
    });

    if (response.ok && response.status >= 200 && response.status < 300) {
      setUploaded(true);
      setTimeout(setUploaded.bind(this, false), 10000);
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.tsx</code> and save to reload.
        </p>

        <input
          type="file"
          onChange={handleFileChange}
        />
        {uploaded &&
        <span className="uploaded">
          Uploaded
        </span>
        }
      </header>
    </div>
  );
}

export default App;
