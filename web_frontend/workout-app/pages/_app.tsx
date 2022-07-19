import "../styles/globals.css";
import type { AppProps } from "next/app";
import { OpenAPI } from "../src/client";
import Head from "next/head";

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <>
      <Component {...pageProps} />
    </>
  );
}

export default MyApp;
