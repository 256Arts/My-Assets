# My Assets

<img src="https://www.256arts.com/myassets/icon_myassets.png" alt="My Assets icon" width="128" align="right">

A birds-eye view of your net worth, built for long-term thinking rather than day-to-day budgeting.

[Download on the App Store](https://apps.apple.com/app/my-assets/id1592367070) · [256arts.com/myassets](https://www.256arts.com/myassets/)

<img src="https://www.256arts.com/myassets/shot1.webp" alt="Summary screen with net worth chart, balance, cash flows, and insights" width="300">

## Features

- **Net worth over time** — a projected chart of where your wealth is headed, years out, not just where it sits today.
- **Assets, debts, and stocks** — track houses, cash, investments, loans, and stock/crypto holdings with live price updates from Alpha Vantage.
- **Income and expenses** — recurring cash flows that feed directly into your net worth projection.
- **Credit cards** — track balances and limits alongside everything else.
- **Live-off-savings insight** — see how many months your savings could sustain you, and how you compare to broader net-worth benchmarks.
- **Apple Intelligence insights** — on-device summaries of your finances on the Summary screen.
- **Siri and Shortcuts** — ask for your net worth, balance, or a 5-year projection, or add an asset, debt, income, or expense hands-free.
- **iCloud sync** — your data syncs across devices automatically.
- iPhone, iPad, Mac, Apple Vision Pro, and Apple Watch.

## Building

Open `My Assets.xcodeproj` and run the `My Assets` scheme (or `My Assets (watchOS) Watch App` for the watch target). Stock prices use the Alpha Vantage key in `My Assets/Secrets.swift`. See [`AGENTS.md`](AGENTS.md) for the architecture.

## Credits

Stock and crypto prices are provided by [Alpha Vantage](https://www.alphavantage.co).
