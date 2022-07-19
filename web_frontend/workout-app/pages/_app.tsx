import "../styles/globals.css";
import type { AppProps } from "next/app";
import { OpenAPI } from "../src/client";
import Head from "next/head";

OpenAPI.BASE = "http://192.168.1.98:8001";

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <>
      <Component {...pageProps} />
    </>
  );
}

export default MyApp;
