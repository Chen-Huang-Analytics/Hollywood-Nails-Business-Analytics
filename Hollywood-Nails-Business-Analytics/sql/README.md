# Hollywood Nails SQL Business Analytics Project

## Project overview
This project demonstrates how salon operations data can be transformed into business insights using PostgreSQL.

## Business context
The case study is modeled on a real service-business environment and uses synthetic customer, appointment, transaction, service, purchasing, and inventory data.

## Important disclosure
All records are synthetic portfolio data. The project should not be presented as audited company data or as containing real customer information.

## Files
- `01_create_schema.sql` — creates tables and indexes
- `02_create_views.sql` — creates reusable analytical views
- `03_business_analysis_queries.sql` — contains 18 business-focused SQL analyses
- `04_portfolio_talking_points.md` — interview and portfolio explanation guide

## Key business questions
- How is revenue changing month over month?
- Which services generate the most revenue and estimated gross profit?
- What percentage of customers return?
- Which customers have the highest lifetime value?
- Which weekdays and hours are busiest?
- What is the cancellation and no-show rate?
- Which booking sources perform best?
- Which employees generate the most revenue?
- How much is spent on inventory and suppliers?
- Which products have the largest inventory variances?
- Which products need reordering?

## Recommended execution order
1. Run `01_create_schema.sql`
2. Import CSV files
3. Run `02_create_views.sql`
4. Run `03_business_analysis_queries.sql`

## Target roles
Operations Analyst, Business Operations Specialist, Revenue Operations Associate, CRM Operations, Junior Data Analyst
