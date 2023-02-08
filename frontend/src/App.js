import React, {useState} from 'react';
import {Socket} from 'phoenix';

import api from './services/Api';
import './App.css';

const CHANNEL = "room:lobby";

function App() {
  const [messages, setMessages] = useState([]);
  const [uploaded, setUploaded] = useState(false);
  const [networkError, setNetworkError] = useState(false);

  let socket = new Socket(api.websocket_url, {params: {someToken: "your general access token"}})
  let channel = socket.channel(CHANNEL, {token: "another access token for the room"})
  channel.on("new_message", msg => {
    setMessages([msg, ...messages]);
  })

  socket.connect()
  channel.join()
    .receive("ok", ({messages}) => {
      setNetworkError(false);
    })
    .receive("error", ({reason}) => {
      setNetworkError(true);
    })
    .receive("timeout", () => {
      setNetworkError(true);
    })

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

  console.log(messages);

  return (
    <div className="App">
      {networkError &&
      <div className="network-error">
        Network error
      </div>
      }
      <div className="App-header">
        <div className="element">
          {uploaded &&
          <span className="uploaded">
            Uploaded
          </span>
          }
        </div>
        <div className="element">
          <input
            type="file"
            onChange={handleFileChange}
          />
        </div>
        <div className="element">
          Events:
        </div>
        {messages.map((msg, index) =>
          <div key={index} className="element event">
            Event: <b>{msg.event}</b>
            <br/>
            {msg.event === "new_file" &&
            <p>
              File info:
              <br/>
              Bucket: <b>{msg.metadata.bucket_name}</b> -- Name: <b>{msg.metadata.object_key}</b>
              <br/>
              Size: <b>{msg.metadata.object_size} bytes</b> -- Uploaded at: <b>{msg.metadata.inserted_at}</b>
              <br/>
            </p>
            }
            Timestamp: <b>{msg.timestamp}</b>
          </div>
        )}
      </div>
    </div>
  );
}

export default App;
