import '../models/scan_document.dart';

class SampleDataService {
  static List<ScanDocument> getSampleDocuments() {
    return [
      ScanDocument(
        title: 'Meeting Notes - Q4 Planning',
        extractedText: '''Q4 Planning Meeting
Date: September 24, 2025
Attendees: John, Sarah, Mike, Lisa

Key Discussion Points:
1. Product roadmap for next quarter
2. Budget allocation for marketing campaigns
3. Team expansion plans
4. Customer feedback integration

Action Items:
- John: Prepare budget proposal by Oct 1
- Sarah: Schedule customer interviews
- Mike: Draft technical specifications
- Lisa: Coordinate with design team

Next Meeting: October 1, 2025 at 2:00 PM''',
        imagePaths: ['assets/sample_doc1.jpg'],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      
      ScanDocument(
        title: 'Invoice - Office Supplies',
        extractedText: '''INVOICE
Invoice #: INV-2025-0924
Date: September 24, 2025

Bill To:
ScanFlow Technologies
123 Innovation Drive
Tech City, TC 12345

Items:
- Office Paper (5 reams) - \$25.00
- Printer Ink Cartridges (3) - \$75.00
- Notebooks (10) - \$30.00
- Pens (2 boxes) - \$15.00

Subtotal: \$145.00
Tax (8.5%): \$12.33
Total: \$157.33

Payment Due: October 24, 2025''',
        imagePaths: ['assets/sample_invoice.jpg'],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      
      ScanDocument(
        title: 'Recipe - Chocolate Chip Cookies',
        extractedText: '''CHOCOLATE CHIP COOKIES

Ingredients:
- 2¼ cups all-purpose flour
- 1 tsp baking soda
- 1 tsp salt
- 1 cup butter, softened
- ¾ cup granulated sugar
- ¾ cup brown sugar
- 2 large eggs
- 2 tsp vanilla extract
- 2 cups chocolate chips

Instructions:
1. Preheat oven to 375°F
2. Mix flour, baking soda, and salt in bowl
3. Cream butter and sugars until fluffy
4. Beat in eggs and vanilla
5. Gradually blend in flour mixture
6. Stir in chocolate chips
7. Drop rounded tablespoons onto ungreased cookie sheets
8. Bake 9-11 minutes until golden brown

Makes about 5 dozen cookies''',
        imagePaths: ['assets/sample_recipe.jpg'],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      
      ScanDocument(
        title: 'Business Card - John Smith',
        extractedText: '''JOHN SMITH
Senior Software Engineer

TechCorp Solutions
john.smith@techcorp.com
(555) 123-4567

LinkedIn: /in/johnsmith-dev
GitHub: @johnsmith-code

"Building the future, one line of code at a time"''',
        imagePaths: ['assets/sample_card.jpg'],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      
      ScanDocument(
        title: 'Multi-page Contract',
        extractedText: '''SERVICE AGREEMENT

This Service Agreement ("Agreement") is entered into on September 20, 2025, between ScanFlow Technologies ("Company") and Client Name ("Client").

1. SCOPE OF SERVICES
The Company agrees to provide the following services:
- Mobile app development
- UI/UX design consultation
- Quality assurance testing
- Deployment and maintenance

2. PAYMENT TERMS
Total project cost: \$50,000
Payment schedule:
- 30% upon signing (\$15,000)
- 40% at milestone completion (\$20,000)
- 30% upon final delivery (\$15,000)

3. TIMELINE
Project duration: 12 weeks
Start date: October 1, 2025
Expected completion: December 24, 2025

4. INTELLECTUAL PROPERTY
All work product shall be owned by the Client upon final payment.

[Additional terms and conditions continue...]''',
        imagePaths: [
          'assets/contract_page1.jpg',
          'assets/contract_page2.jpg',
          'assets/contract_page3.jpg'
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }
}