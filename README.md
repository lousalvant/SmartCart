# SmartCart

## Table of Contents

1. [Overview](#Overview)
2. [Product Spec](#Product-Spec)
3. [Wireframes](#Wireframes)
4. [Schema](#Schema)

## Overview

### Description

SmartCart helps shoppers stay on budget by allowing them to scan price tags or enter in the price manually as they shop, providing a real-time total with sales tax based on location. Shoppers can set a budget, and CartCheck will alert them if they’re close to exceeding it, making it easy to avoid checkout surprises and stay on track.

### App Evaluation

- **Category:** Shopping, Budgeting
- **Mobile:** This app is designed specifically for mobile use to allow for on-the-go price tracking while shopping.
- **Story:**  SmartCart empowers shoppers to take control of their spending, helping them stay within budget and avoid surprises at checkout. With a simple scan or manual entry, users gain clarity on their total spending and make more mindful shopping decisions.
- **Market:** The primary audience includes budget-conscious shoppers, students, and families looking to manage grocery expenses effectively. It’s also useful for anyone who wants a quick and easy way to track spending while shopping.
- **Habit:** This app is likely to be used occasionally, mostly during shopping trips, making it a tool users reach for when they’re actively in stores.
- **Scope:** The app has a narrow scope, focusing on core budgeting and tracking features that help users tally grocery costs.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User can scan a price tag to capture the item’s price.
* User can manually enter the price of an item if scanning is unavailable.
* User can view a real-time total of all items in the cart, including tax based on location.
* User can set a budget for the shopping trip.
* User receives an alert when the total cost is approaching or exceeding their set budget.

**Optional Nice-to-have Stories**

* User can view a breakdown of items added to the cart, including price, quantity, and tax.
* User can categorize items (e.g., groceries, household supplies) for better tracking.
* User can save a shopping list and access it during future trips.
* User can view a summary of past shopping trips and total expenditures.
* User can share their cart total or shopping list with others.
* User can apply discounts or coupons to specific items to see updated totals.

### 2. Screen Archetypes

- [ ] Login Screen / Register Screen
* Required User Feature: User can log in to their account.
* Required User Feature: User can create a new account.
- [ ] Home Screen
* Required User Feature: User can view a "Start Shopping" button to access settings for a new shopping session.
* Optional User Feature: User can navigate to Spending History Screen for a breakdown of grocery spending.
- [ ] Overall Setting Screen
* Required User Feature: User can select a specific grocery store.
* Required User Feature: User can set a budget for the shopping trip.
* Required User Feature: User can access and modify their grocery list before starting.
- [ ] Shopping Screen
* Required User Feature: User can scan a price tag to capture the item’s price.
* Required User Feature: User can manually enter the price of an item if scanning is unavailable.
* Required User Feature: User can view a running total with tax included.
- [ ] Cart Summary Screen
* Required User Feature: User can view an itemized list of all items in the cart.
* Optional Feature: User can view a breakdown of items by category, price, and tax.
* Optional Feature: User can apply discounts or coupons to items for updated totals.
* Optional Feature: User can share their cart summary with others.
- [ ] Spending History Screen
* Optional Feature: User can view monthly spending breakdown by category (e.g., groceries, household items).
* Optional Feature: User can view summaries of past shopping trips and compare spending month-over-month.


### 3. Navigation

**Tab Navigation** (Tab to Screen)


- [ ] First tab, Home Screen
- [ ] Second tab, Settings Screen
- [ ] Third tab, Shopping Screen
- [ ] Fourth tab, Cart Summary Screen
- [ ] Fifth tab, Spending History screen

**Flow Navigation** (Screen to Screen)

- [ ] Login/Sign Up Screen
  * Leads to Home Screen after successful login/sign up.
- [ ] Home Screen
  * Leads to Settings Screen (to set budget, list, and store) through a "Start Shopping" button.
  * Leads to Spending History Screen to view the breakdown of overall grocery spending
- [ ] Settings Screen
* Leads to Shopping Screen after the user sets the store, budget, and grocery list
- [ ] Shopping Screen
* Leads to Scan/Manual entry screen
* Leads to Cart Summary Screen after adding items to the cart
- [ ] Cart Summary Screen
* Leads back to Home Screen after viewing the itemized cart breakdown
- [ ] Spending History Screen
* Leads back to Home Screen after reviewing monthly and overall grocery spending


## Wireframes

![](https://i.imgur.com/jKc7Fxh.png)

## Schema 


### Models

[Model Name, e.g., User]
| Property | Type   | Description                                  |
|----------|--------|----------------------------------------------|
| username | String | Unique id for the user post (default field)   |
| password | String | User's password for login authentication      |
| email      | String    | User's email address
| session_id | String, Primary Key |Unique identifier for each shopping session 
| store_name | String | Name of the selected grocery store
| budget | Decimal | User's budget for shopping session
| created_at | DateTime | Date and time the session was created
| total_spent | Decimal | Total amount spent in session
| status | String | Status of session (active, completed)
| item_id | String, Primary Key | Unique identifier for each item
| item_name | String | Name of item
| price | Decimal | Price of item
| tax_included | Boolean | Boolean to indicate if tax was applied to item
| summary_id | String, Primary Key | Unique identifier for each cart summary
| total_items | Integer | Total number of items in the cart
| total_price | Decimal | Total price of all items before tax
|total_tax | Decimal | Total tax applied to all items
| final_total | Decimal | Total amount including tax
| discounts_applied | String | Any discounts or coupons applied
| history_id |String, Primary Key | Unique identifier for each history record
| month_year | String | Month and year of the record
| total_spent_monthly | Decimal | Total amount spent in the month
| sessions | Array of Strings | List of session_ids for session that occured in the month


### Networking

#### Login Screen / Register Screen

- [POST] /register - Create a new user account with username, password, and email.
- [POST] /login - Authenticate user with username and password.

#### Home Screen

- [GET] /spending_history - Fetch user's monthly spending history.
- [GET] /shopping_sessions - Retrieve active or recent shopping sessions.

#### Settings Screen

- [POST] /shopping_session - Create a new shopping session with store name, budget, and list.
- [GET] /grocery_list - Retrieve user’s saved grocery list for the session.

#### Shopping Screen

- [POST] /grocery_item - Add an item to the current shopping session.
- [GET] /shopping_session/total - Fetch the running total of the shopping session, including tax.

#### Cart Summary Screen

- [GET] /cart_summary - Retrieve the itemized list of all items in the current cart with prices and tax.
- [POST] /apply_discount - Apply a discount or coupon to the cart.

#### Spending History Screen

- [GET] /spending_history - Retrieve historical spending data by month and category.
