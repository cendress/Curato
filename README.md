# Curato

Curato is a swipe-based shopping experience built to make personalization feel faster, more intuitive, and more engaging.

Instead of relying only on rigid keyword search or slow passive signals, Curato lets users express taste through lightweight interactions. Users enter a shopping intent like **“minimal spring outfits for NYC under $150”**, then browse a live swipe deck of products that reranks in real time based on their feedback.

Built in 24 hours at **The Phia Hack**, where it won **Best UI/UX**.

## Overview

Most people do not start shopping with a perfectly precise search term. They usually have a vibe, a mood, an occasion, or a rough aesthetic in mind.

Curato explores what shopping discovery might look like if users could communicate taste quickly and directly, rather than digging through filters or waiting for recommendation systems to slowly learn from weak signals like clicks and page views.

The result is a native iOS shopping app focused on:
- faster preference capture
- more intuitive discovery
- real-time recommendation feedback
- a more playful, product-led browsing experience

## Features

- Lightweight onboarding flow for shopping intent, budget, and category preferences
- Swipeable product deck with live shopping results
- Save items for later
- Open detailed product views
- Filter by vibe, budget, category, and style framing
- Local reranking based on user interactions
- Short recommendation explanations for why each item was shown

## How It Works

Curato retrieves live shopping data and normalizes it into a local product model. On top of that, it runs a lightweight recommendation system entirely on-device.

The app:
- parses the user’s vibe input into tags
- infers tags for products from titles, merchants, and snippets
- scores products based on:
  - vibe match
  - category match
  - budget fit
  - user feedback
- reranks products after every like, skip, or save
- generates a short explanation based on the strongest matching signals

## Tech Stack

- **SwiftUI** for the full interface
- **MVVM** for app structure and state flow
- **SwiftData** for local persistence
- **URLSession** for networking
- **SerpApi Google Shopping API** for live product retrieval
- **Swift Testing** for validating core logic

## Architecture

Curato is a native iOS app with no backend.

It calls the Google Shopping API through SerpApi directly from the client, retrieves live results, and transforms them into an internal `Product` model. Recommendation logic, state updates, onboarding state, and saved items are all managed locally on-device.

This kept the project fast to build while still creating a full product loop:
1. capture intent
2. retrieve products
3. score + rank results
4. capture feedback
5. rerank in real time

## Challenges

### Stable swipe deck layout
Card-based interfaces can feel broken quickly if layout shifts while the next card becomes active. I ran into issues with flickering and resizing as cards transitioned.

I solved this by:
- giving the swipe deck a stable shared frame
- rendering each card inside that fixed layout
- only animating transforms like offset, rotation, and opacity
- making sure the next visible card did not accidentally share the same ID as the current one

### Persistence
I wanted the app to remember:
- onboarding state
- saved products
- user preference signals

Using SwiftData allowed the app to reopen in a coherent, personalized state without needing a backend.

## What I Learned

This project reinforced how much product speed today comes from strong strategy, research, and prompt development, not just raw implementation.

It also taught me:
- how to structure a SwiftUI codebase for speed without letting it become chaotic
- how to use SwiftData effectively for lightweight local persistence
- how simple, explainable recommendation logic can feel powerful when the interaction loop is tight

More broadly, Curato made me think about interaction design as a faster way to learn user taste. That feels relevant not just for shopping, but for personalization problems more broadly.

## What’s Next

If I continued building Curato, I would want to:
- improve the ranking logic
- expand filtering and preference controls
- test how tightly-coupled feedback loops affect recommendation quality over time

## Built With

- iOS
- Swift
- SwiftUI
- SwiftData
- Swift Testing
- URLSession
- SerpApi
- Xcode

## Links

- [Devpost](https://devpost.com/software/curato-5lkcbt?_gl=1*og31m0*_gcl_au*MjAwNzU5OTU0LjE3NzY2MTE1NTI.*_ga*Nzk4ODEwOTg3LjE3NzY2MTE1NTM.*_ga_0YHJK3Y10M*czE3NzY3OTk1NjUkbzUkZzEkdDE3NzY4MDc2OTkkajU0JGwwJGgw)
- [GitHub Repository](https://github.com/cendress/Curato)

## Author

**Christopher Endress**  
iOS engineer focused on SwiftUI, product craftsmanship, and building consumer apps people actually enjoy using.

- [LinkedIn](https://www.linkedin.com/in/christopher-endress-03bb8a291/)
- [X / Twitter](https://x.com/chrisendress_io)
