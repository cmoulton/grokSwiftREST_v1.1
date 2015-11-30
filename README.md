# Demo Code for [iOS Apps with REST APIs: Building Web-Driven Apps in Swift](https://leanpub.com/iosappswithrest)

You need to build an iOS app around your team's API or integrate a third party API. You need a quick, clear guide to demystify Xcode and Swift. No esoteric details about Core Anything or mathematical proofs of KVO's features. Only the nitty gritty that you need to get real work done now: pulling data from your web services into an iOS app without tossing your MacBook or Mac Mini through a window.

You just need the bare facts on how to get CRUD done on iOS. That's what this book will do for you.

## What will you be able to do?

After reading this book you'll be able to:

- Analyze a JSON response from a web service call and write Swift code to parse it into model objects.
- Display those model objects in a table view so that when the user launches the app they have a nice list to scroll through.
- Add authentication to use web service calls that require OAuth 2.0, a username/password, or a token.
- Transition from the main table view to a detail view for each object, possibly making another web service call to get more info about the object.
- Let users of your app add, modify and delete objects (as long as your web service supports it).
- Hook in to more web service calls to extend you app, like adding user profiles or letting users submit comments or attach photos to objects.

To achieve those goals we'll build out an app based on the GitHub API, focusing on gists. *(If you're not familiar with gists, they're basically just text snippets, often code owned by a user on GitHub.)* Your model objects might be bus routes, customers, chat messages, or whatever kind of object is core to your app. So our demo app will:

We'll start by figuring out how to make API calls in Swift then we'll start building out our app one feature at a time:

- Show a list of all public gists in a table view
- Load more results when the user scrolls down
- Let them pull to refresh to get the latest public gists
- Load images from URLs into table view cells
- Use OAuth 2.0 for authentication to get a list of a user's private gists
- Have a detail view for each gist showing the text
- Allow users to add new gists, edit their own existing gists, and delete gists

Then we'll discuss handling not having a network connection.

## Who is this book for?

- Software developers getting started with iOS but experienced in other languages
- Front-end devs looking to implement native UIs for iOS apps (no CSS, oh noes!)
- Back-end devs tasked with getting the data into the user's hands on iOS
- Android, Windows Phone, Blackberry, Tizen, Symbian & Palm OS devs looking to expand their web service backed apps to iOS
- Anyone whose boss is standing over their shoulder asking with the API data isn't showing up in the table view yet

## Who is this book not for?

- Complete newcomers to programming, you should have a decent grasp of at least one object-oriented programming language or have completed several intro to iOS tutorials
- Designers, managers, UX pros, ... It's a programming book. All the monospace font inserts will probably drive you crazy.
- Cross-platform developers dedicated to their tools (including HTML5 & Xamarin), this is all Swift & native UI, all the time
- Programmers building apps that have little or no web service interaction
- Game devs, unless you're tying in a REST-like API

## Using This Book

This book is mostly a tutorial in implementing the gists app. Depending on how you learn best and how urgently you need to implement your own app, there are 2 different approaches you might take:

1. Work through the tutorials as written, creating an app for GitHub Gists. You'll understand how that app works and later be able to apply it to your own apps.
2. Read through the tutorials but implement them for your own app and API. Throughout the text I'll point out where you'll need to analyze your own requirements and API to help you figure out how to modify the example code to work with your API. Those tips will look like this:

> List the tasks or user stories for your app. Compare them to the list for the gists app, focusing on the number of different objects (like stars, users. and gists) and the types of action taken (like viewing a list, viewing an object's details, adding, deleting, etc.).

We'll start with that task in the first chapter. We'll analyze our requirements and figure out just what we're going to build. Then we'll start building the gists app, right after an introduction to making network calls and parsing JSON in Swift.

## What do we mean by Web Services / APIs / REST / CRUD

Like anything in tech there are plenty of buzzwords around web services. For a while it was really trendy to say your web services were RESTful. If you want to read the theory behind it, head over to [Wikipedia](https://en.wikipedia.org/wiki/Representational_state_transfer). For our purposes in this book, all we mean by "REST web service" or even most of the time that we say "web service" or "API" is that we can send an HTTP request and we get back some data in a format that's easy to use in our app. Usually the response will be in JSON.

Web services are wonderful since they let you use existing systems in your own apps. They're always a bit of a pain since every one has it's own quirks but most of the integration is similar enough that we can generalize how to integrate them into our iOS apps.

In other words, if you want an argument about whether or not a web service is really RESTful you're not going to find it here. We've got work that just needs to get *done*.

## JSON

In this book we're going to deal with web services that return JSON. JSON hugely common these days. Of course, there are other return types out there, like XML. This book won't cover responses in anything but JSON but it will encapsulate the JSON parsing so that you can replace it with whatever you need to without having to touch a ton of code.

## Versions

This is version 1.1 of this book. It uses Swift 2.0, iOS 9, and Xcode 7. When we use libraries we'll explicitly list the versions used. The most commonly used ones are Alamofire 3.1 and SwiftyJSON 2.3.0.

[Version 1.0](https://github.com/cmoulton/grokSwiftREST) of this book used Alamofire 2.0 and SwiftyJSON 2.2.0.

## Source Code

All sample code is available [on GitHub](https://github.com/cmoulton/grokSwiftREST_v1.1) under the [MIT license](https://github.com/cmoulton/grokSwiftREST_v1.1/blob/master/LICENSE). Links are provided throughout the text. Each chapter has a tag allowing you to check out the code in progress up to the end of that chapter.

Individuals are welcome to use code for commercial and open-source projects. As a courtesy, please provide attribution to “Teak Mobile Inc.” or "Christina Moulton". For more information, review the complete Github license agreement.

<a href="https://leanpub.com/iosappswithrest/">Buy now for $29</a>
<p>or <a href="https://leanpub.com/iosappswithrest/">read the free sample chapters</a></p>
