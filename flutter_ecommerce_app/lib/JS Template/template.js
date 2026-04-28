
    title E-commerce App Sequence Diagram

    %% User Flow
    participant User
    participant ProductPage
    participant CartPage
    participant OrderService
    participant Firebase

    User->>ProductPage: View Product Details
    ProductPage->>Firebase: Fetch Product Data
    Firebase-->>ProductPage: Return Product Data

    User->>CartPage: Add Product to Cart
    CartPage->>Firebase: Update Cart Data

    User->>CartPage: Proceed to Checkout
    CartPage->>OrderService: Create Order
    OrderService->>Firebase: Save Order Data

  
    OrderService->>Firebase: Update Order Status

    CartPage-->>User: Show Confirmation

    %% Admin Flow
    participant Admin
    participant AdminOrderEditPage

    Admin->>LoginPage: Log In
    LoginPage->>Firebase: Verify Credentials
    Firebase-->>LoginPage: Authentication Success

    Admin->>AdminOrderEditPage: View Orders
    AdminOrderEditPage->>Firebase: Fetch Order Data
    Firebase-->>AdminOrderEditPage: Return Order Data

    Admin->>AdminOrderEditPage: Edit Order
    AdminOrderEditPage->>Firebase: Update Order Data

    AdminOrderEditPage-->>Admin: Show Confirmation