# Assignment 1: Design a Logical Model

## Question 1
Create a logical model for a small bookstore. 📚

At the minimum it should have employee, order, sales, customer, and book entities (tables). Determine sensible column and table design based on what you know about these concepts. Keep it simple, but work out sensible relationships to keep tables reasonably sized. Include a date table. There are several tools online you can use, I'd recommend [_Draw.io_](https://www.drawio.com/) or [_LucidChart_](https://www.lucidchart.com/pages/).

## Question 2
We want to create employee shifts, splitting up the day into morning and evening. Add this to the ERD.

## Question 3
The store wants to keep customer addresses. Propose two architectures for the CUSTOMER_ADDRESS table, one that will retain changes, and another that will overwrite. Which is type 1, which is type 2?

_Hint, search type 1 vs type 2 slowly changing dimensions._

Bonus: Are there privacy implications to this, why or why not?
```
1. Type 1 Slowly Changing Dimension (SCD)
   a) Overwrite: this architecture simply updates (overwrites) the new address whenever there's a change in the customer's address. Only the latest address information is retained, and there is no historical tracking of changes.

   b) Schema: the schema of the 'CUSTOMER_ADDRESS' table would typically include columns such as 
   'customer_id', 
   'address', 
   'city', 
   'state', 
   'country', 
   'zip_code'.

   c) SQL statement: 
   "UPDATE customer_address SET c1=v1, ... WHERE customer_id ='...'".

2. Type 2 Slowly Changing Dimension (SCD)
   a) Insert: this architecture simply keeps all historical changes to the customer addresses. Each time there's a change in the table, a new record is inserted into the database, preserving the history of changes over time.
   b) Schema: the schema of the 'CUSTOMER_ADDRESS' table would typically include columns such as 
   'customer_id', 
   'address', 
   'city', 
   'state', 
   'country', 
   'zip_code', 
   'address_id', (new Primary Key)
   'status' and 'time_stamp'. (additional columns)
   
   Given that the 'customer_id' duplicates with every change in the address, a new primary key (PK) is needed. 'address_id' will serve as a reference  to the 'customer' table.

   When a customer's address becomes outdated, the 'status' column will receive an integer value to denote its invalidity. Subsequently, the new address will be inserted into the table as a new row with its 'status' column set to 'null', signifying its current validity. Only the most recent address entry will possess a 'null' status. It is advisable to index the 'status' column to enhance query performance. 
   
   The 'time_stamp' column records the date and time precisely when an outdated record becomes invalid. This timestamp functionality serves to efficiently organize and sort all historical addresses in chronological order.

   c) Two SQL statements: (One to insert new address information, and another to update outdated entries)
   ' INSERT INTO customer_address (col1, col2, ...) VALUES(value1, value2, ...)'. 
   'UPDATE customer_address SET status = 1, time_stamp=julianday('now')  WHERE customer_id='...'.

   d) 'SELECT' statement: the SQL statement for 'SELECT' will be amended to include a 'WHERE' condition: 'WHERE status is not null'. This ensures that only the latest valid information is retrieved. This optimization eliminates the need to compare timestamps to identify the most recent address, thus enhancing database performance, particularly when 'status' is indexed. 

   e) 'DELETE' statement: the integer value assigned to 'status' can accomodate various scenarios, allowing  the database to preserve data instead of deletion. Different values may signify different reasons for invalidity, aiding in data management and retrieval.
   
 - 3. Privacy implication
    a) Data Breach Risk: Storing customer addresses increases the potential impact of a data breach. If unauthorized parties gain access to the database, they could exploit this sensitive information for identity theft.

    b) Compliance Issues: Depending on the jurisdiction and the nature of the stored data, there might be legal requirements regarding the storage and protection of customer addresses. Failure to comply with these regulations could result in sustantial fines or legal repercussion.

    c) Customer Trust: Customers may be concerned about their privacy and the security of their personal information. If they perceive that their addresses are not being adequately protected, it could undermine their trust in the business and lead to customer dissatisfaction or even loss of business.


```

## Question 4
Review the AdventureWorks Schema [here](https://i.stack.imgur.com/LMu4W.gif)

Highlight at least two differences between it and your ERD. Would you change anything in yours?
```
Your answer...
```

# Criteria

[Assignment Rubric](./assignment_rubric.md)

# Submission Information

🚨 **Please review our [Assignment Submission Guide](https://github.com/UofT-DSI/onboarding/blob/main/onboarding_documents/submissions.md)** 🚨 for detailed instructions on how to format, branch, and submit your work. Following these guidelines is crucial for your submissions to be evaluated correctly.

### Submission Parameters:
* Submission Due Date: `June 1, 2024`
* The branch name for your repo should be: `model-design`
* What to submit for this assignment:
    * This markdown (design_a_logical_model.md) should be populated.
    * Two Entity-Relationship Diagrams (preferably in a pdf, jpeg, png format).
* What the pull request link should look like for this assignment: `https://github.com/<your_github_username>/sql/pull/<pr_id>`
    * Open a private window in your browser. Copy and paste the link to your pull request into the address bar. Make sure you can see your pull request properly. This helps the technical facilitator and learning support staff review your submission easily.

Checklist:
- [ ] Create a branch called `model-design`.
- [ ] Ensure that the repository is public.
- [ ] Review [the PR description guidelines](https://github.com/UofT-DSI/onboarding/blob/main/onboarding_documents/submissions.md#guidelines-for-pull-request-descriptions) and adhere to them.
- [ ] Verify that the link is accessible in a private browser window.

If you encounter any difficulties or have questions, please don't hesitate to reach out to our team via our Slack at `#cohort-3-help`. Our Technical Facilitators and Learning Support staff are here to help you navigate any challenges.
