# Academic Fee Filtering System

## Overview

The MyEdu app includes a sophisticated fee filtering system that allows different types of fees to be shown to specific students based on various criteria. This system supports multiple target types to ensure students only see relevant fees.

## Fee Target Types

### 1. **All** - Universal Fees
- **Target Type**: `"All"`
- **Target Value**: `""` (empty string)
- **Behavior**: Shows the fee to all students
- **Use Case**: General fees like tuition, registration, etc.

### 2. **Individual** - Student-Specific Fees
- **Target Type**: `"Individual"`
- **Target Value**: Student's Academic ID (e.g., `"2002010"`)
- **Behavior**: Shows the fee only to the specific student whose academic ID matches
- **Use Case**: Late fees, outstanding fines, special assessments, individual penalties

### 3. **Class** - Class-Level Fees
- **Target Type**: `"Class"`
- **Target Value**: Class identifier (e.g., `"6th"`, `"7th"`)
- **Behavior**: Shows the fee to all students in that specific class
- **Use Case**: Class-specific lab fees, class events, etc.

### 4. **Year** - Year-Level Fees
- **Target Type**: `"Year"`
- **Target Value**: Academic year identifier (e.g., `"20-21"`, `"21-22"`)
- **Behavior**: Shows the fee to all students in that academic year
- **Use Case**: Year-specific fees, batch events, etc.

## Filtering Logic

The system uses the following logic to determine which fees to show:

```dart
bool _shouldShowFee(AcademicFeeModel fee) {
  // Get current user from AuthController
  final authController = Get.find<AuthController>();
  final currentUser = authController.user;
  
  // If targetType is 'All', show all bills
  if (fee.targetType == 'All') {
    return true;
  }

  // If targetType is 'Individual', check if targetValue matches user's academic ID
  if (fee.targetType == 'Individual' && currentUser != null) {
    return fee.targetValue == currentUser.id;
  }

  // If targetType is not 'All' or 'Individual', only show bills where targetValue matches '6th' or '20-21'
  if (fee.targetType != 'All' && fee.targetType != 'Individual') {
    return fee.targetValue == '6th' || fee.targetValue == '20-21';
  }

  // Otherwise, don't show the bill
  return false;
}
```

## Implementation Details

### AcademicFeesController (`lib/controllers/academic_fees_controller.dart`)

The filtering logic is implemented in the `_shouldShowFee` method within the `filteredFees` getter:

```dart
List<AcademicFeeModel> get filteredFees {
  var fees = academicFees.where((fee) {
    // First, apply target filtering based on targetType and targetValue
    if (!_shouldShowFee(fee)) {
      return false;
    }

    // Search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      if (!fee.purpose.toLowerCase().contains(query) &&
          !(fee.description?.toLowerCase().contains(query) ?? false)) {
        return false;
      }
    }

    // Status filter
    switch (selectedFilter.value) {
      case 'pending':
        return fee.currentStatus == FeeStatus.pending;
      case 'paid':
        return fee.currentStatus == FeeStatus.paid;
      case 'overdue':
        return fee.currentStatus == FeeStatus.overdue;
      default:
        return true;
    }
  }).toList();

  // Sort by priority: overdue first, then by due date
  fees.sort((a, b) {
    if (a.currentStatus == FeeStatus.overdue &&
        b.currentStatus != FeeStatus.overdue) {
      return -1;
    }
    if (b.currentStatus == FeeStatus.overdue &&
        a.currentStatus != FeeStatus.overdue) {
      return 1;
    }
    return a.deadline.compareTo(b.deadline);
  });

  return fees;
}
```

### User Model Integration

The system uses the `UserModel.id` field to match Individual target fees:

```dart
class UserModel {
  final String id; // This is the academic ID used for Individual fee matching
  // ... other fields
}
```

## Firestore Data Structure

### Fee Document Structure

```json
{
  "purpose": "Fee Purpose",
  "amount": 1000,
  "deadline": "2025-06-15T00:00:00Z",
  "createdAt": "2025-05-01T00:00:00Z",
  "status": "pending",
  "type": "tuition",
  "description": "Fee description",
  "semester": "Spring 2025",
  "academicYear": "2024-25",
  "isRecurring": false,
  "applicableFaculties": [],
  "lateFee": 100,
  "discount": null,
  "targetType": "Individual", // "All", "Individual", "Class", "Year"
  "targetValue": "2002010", // Academic ID for Individual, class/year for others
  "items": [
    {
      "name": "Item Name",
      "amount": 500,
      "description": "Item description"
    }
  ]
}
```

## Examples

### Example 1: Universal Fee (All Students)
```json
{
  "purpose": "Tuition Fee - Spring 2025",
  "amount": 15000,
  "targetType": "All",
  "targetValue": "",
  "status": "pending"
}
```
**Result**: All students see this fee

### Example 2: Individual Fee (Specific Student)
```json
{
  "purpose": "Late Fee - Special Assessment",
  "amount": 2500,
  "targetType": "Individual",
  "targetValue": "2002010",
  "status": "pending"
}
```
**Result**: Only student with academic ID "2002010" sees this fee

### Example 3: Class Fee (6th Class Students)
```json
{
  "purpose": "Lab Fee - Chemistry",
  "amount": 3000,
  "targetType": "Class",
  "targetValue": "6th",
  "status": "pending"
}
```
**Result**: All students in 6th class see this fee

### Example 4: Year Fee (20-21 Batch)
```json
{
  "purpose": "Library Fee",
  "amount": 1500,
  "targetType": "Year",
  "targetValue": "20-21",
  "status": "pending"
}
```
**Result**: All students in 20-21 academic year see this fee

## Use Cases

### Individual Fees
- **Late Submission Penalties**: Specific to students who submitted documents late
- **Outstanding Fines**: Library fines, equipment damage fees
- **Special Assessments**: Individual student assessments or penalties
- **Outstanding Balances**: Individual payment reminders

### Class Fees
- **Lab Fees**: Specific to certain classes (e.g., Chemistry lab for 6th class)
- **Class Events**: Fees for class-specific activities
- **Class Materials**: Textbooks or materials for specific classes

### Year Fees
- **Batch Events**: Fees for year-specific events or activities
- **Year-specific Services**: Services available only to certain academic years
- **Batch Discounts**: Special fees or discounts for specific years

### Universal Fees
- **Tuition Fees**: Standard fees for all students
- **Registration Fees**: General registration charges
- **Development Fees**: Infrastructure fees for all students

## Testing

### Test Scenarios

1. **Individual Fee Testing**:
   - Create a fee with `targetType: "Individual"` and `targetValue: "2002010"`
   - Login as student with ID "2002010" → Should see the fee
   - Login as student with ID "2002011" → Should NOT see the fee

2. **Class Fee Testing**:
   - Create a fee with `targetType: "Class"` and `targetValue: "6th"`
   - Login as student in 6th class → Should see the fee
   - Login as student in 7th class → Should NOT see the fee

3. **Year Fee Testing**:
   - Create a fee with `targetType: "Year"` and `targetValue: "20-21"`
   - Login as student in 20-21 batch → Should see the fee
   - Login as student in 21-22 batch → Should NOT see the fee

4. **Universal Fee Testing**:
   - Create a fee with `targetType: "All"`
   - Login as any student → Should see the fee

### Test Data

Use the sample data in `lib/data/sample_academic_fees_data.dart` for testing different scenarios.

## Security Considerations

### Data Privacy
- Individual fees are only visible to the specific student
- No other students can see individual fees
- User authentication is required for fee filtering

### Access Control
- Fee filtering happens on the client side after authentication
- Server-side validation should also be implemented for production
- User session management ensures proper access control

## Future Enhancements

### Planned Features
1. **Faculty-based Filtering**: Show fees based on student's faculty
2. **Date-based Filtering**: Show fees based on enrollment dates
3. **Role-based Filtering**: Different fees for different user roles
4. **Dynamic Filtering**: Real-time fee updates based on student status

### Technical Improvements
1. **Server-side Filtering**: Move filtering logic to backend
2. **Caching**: Cache filtered results for better performance
3. **Batch Operations**: Handle multiple fee types efficiently
4. **Analytics**: Track fee visibility and student interactions

## Troubleshooting

### Common Issues

1. **Individual Fees Not Showing**:
   - Check if `targetValue` matches the user's academic ID exactly
   - Verify user authentication is working
   - Check if the user object is properly loaded

2. **Class/Year Fees Not Showing**:
   - Verify `targetValue` matches the expected format
   - Check if the filtering logic includes the correct values
   - Ensure the fee document structure is correct

3. **All Fees Not Showing**:
   - Check if `targetType` is set to "All"
   - Verify the fee document is properly saved in Firestore
   - Check for any JavaScript errors in the console

### Debug Steps

1. **Check User Data**:
   ```dart
   print('User ID: ${authController.user?.id}');
   print('User Name: ${authController.user?.name}');
   ```

2. **Check Fee Data**:
   ```dart
   print('Fee Target Type: ${fee.targetType}');
   print('Fee Target Value: ${fee.targetValue}');
   ```

3. **Check Filtering Logic**:
   ```dart
   print('Should Show Fee: ${_shouldShowFee(fee)}');
   ```

## Support

For technical support or questions about the fee filtering system:
- **Email**: support@myedu.edu.bd
- **Phone**: +880-4427-56072
- **Documentation**: This README file

---

**Last Updated**: December 2024
**Version**: 2.0.0
**Author**: MyEdu Development Team 