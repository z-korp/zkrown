import ReactDOM from "react-dom/client";
import InitApp from "./components/InitApp.tsx";
import "./index.css";

async function init() {
  const rootElement = document.getElementById("root");
  if (!rootElement) throw new Error("React root not found");
  const root = ReactDOM.createRoot(rootElement as HTMLElement);

  root.render(<InitApp />);
}

init();
