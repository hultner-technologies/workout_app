import "../styles/globals.css";
import type { AppProps } from "next/app";
import { OpenAPI } from "../src/client";
import Head from "next/head";
import Container from "@mui/material/Container";
import { IntlProvider } from "react-intl";

OpenAPI.BASE = `http://${
  typeof window !== "undefined"
    ? window?.location?.hostname ?? "localhost"
    : "localhost"
}:8001`;

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <>
      <IntlProvider messages={{}} locale="sv" defaultLocale="sv">
        <Head>
          <meta
            name="viewport"
            content="width=device-width, initial-scale=1.0, user-scalable=no, viewport-fit=cover"
          />
          <meta name="apple-mobile-web-app-capable" content="yes" />
          <link rel="manifest" href="/manifest.json" />
        </Head>
        <Container>
          <Component {...pageProps} />
        </Container>
      </IntlProvider>
    </>
  );
}

export default MyApp;
