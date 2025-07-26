import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";
import "bulma/css/bulma.css";

// Force cache bust - updated for ingress routing
const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(<App />);

