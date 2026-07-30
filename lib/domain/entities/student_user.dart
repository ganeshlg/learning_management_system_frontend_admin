class StudentUser {
  final int id;
  final String name;
  final String email;
  final String? password;
  final String? courseId;
  final String? fullName;
  final String? passportPhotoUrl;
  final String? dateOfBirth;
  final String? gender;
  final String? mobileNumber;
  final String? address;
  final String? cityStatePin;
  final String? emergencyContact;
  final String? educationalQualification;
  final String? collegeUniversity;
  final String? yearOfGraduation;
  final String? currentStatus;
  final String? currentOrganization;
  final String? totalExperience;
  final String? businessName;
  final String? areasOfInterest;
  final String? whyJoinProgram;
  final String? businessIdea;
  final String? skillsToDevelop;
  final String? howHeardAboutProgram;
  final String? documentsEnclosed;
  final String? declaration;
  final String? signature;
  final String? declarationDate;
  final String? paymentPlan;
  final int? paidInstallments;

  StudentUser({
    required this.id,
    required this.name,
    required this.email,
    this.password,
    this.courseId,
    this.fullName,
    this.passportPhotoUrl,
    this.dateOfBirth,
    this.gender,
    this.mobileNumber,
    this.address,
    this.cityStatePin,
    this.emergencyContact,
    this.educationalQualification,
    this.collegeUniversity,
    this.yearOfGraduation,
    this.currentStatus,
    this.currentOrganization,
    this.totalExperience,
    this.businessName,
    this.areasOfInterest,
    this.whyJoinProgram,
    this.businessIdea,
    this.skillsToDevelop,
    this.howHeardAboutProgram,
    this.documentsEnclosed,
    this.declaration,
    this.signature,
    this.declarationDate,
    this.paymentPlan,
    this.paidInstallments,
  });

  factory StudentUser.fromJson(Map<String, dynamic> json) {
    return StudentUser(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id']?.toString() ?? '0'),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'],
      courseId: json['course_id'],
      fullName: json['full_name'],
      passportPhotoUrl: json['passport_photo_url'],
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      mobileNumber: json['mobile_number'],
      address: json['address'],
      cityStatePin: json['city_state_pin'],
      emergencyContact: json['emergency_contact'],
      educationalQualification: json['educational_qualification'],
      collegeUniversity: json['college_university'],
      yearOfGraduation: json['year_of_graduation'],
      currentStatus: json['current_status'],
      currentOrganization: json['current_organization'],
      totalExperience: json['total_experience'],
      businessName: json['business_name'],
      areasOfInterest: json['areas_of_interest'],
      whyJoinProgram: json['why_join_program'],
      businessIdea: json['business_idea'],
      skillsToDevelop: json['skills_to_develop'],
      howHeardAboutProgram: json['how_heard_about_program'],
      documentsEnclosed: json['documents_enclosed'],
      declaration: json['declaration'],
      signature: json['signature'],
      declarationDate: json['declaration_date'],
      paymentPlan: json['payment_plan'],
      paidInstallments: json['paid_installments'] is int ? json['paid_installments'] as int : int.tryParse(json['paid_installments']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'course_id': courseId,
      'full_name': fullName,
      'passport_photo_url': passportPhotoUrl,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'mobile_number': mobileNumber,
      'address': address,
      'city_state_pin': cityStatePin,
      'emergency_contact': emergencyContact,
      'educational_qualification': educationalQualification,
      'college_university': collegeUniversity,
      'year_of_graduation': yearOfGraduation,
      'current_status': currentStatus,
      'current_organization': currentOrganization,
      'total_experience': totalExperience,
      'business_name': businessName,
      'areas_of_interest': areasOfInterest,
      'why_join_program': whyJoinProgram,
      'business_idea': businessIdea,
      'skills_to_develop': skillsToDevelop,
      'how_heard_about_program': howHeardAboutProgram,
      'documents_enclosed': documentsEnclosed,
      'declaration': declaration,
      'signature': signature,
      'declaration_date': declarationDate,
      'payment_plan': paymentPlan,
      'paid_installments': paidInstallments,
    };
  }

  StudentUser copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? courseId,
    String? fullName,
    String? passportPhotoUrl,
    String? dateOfBirth,
    String? gender,
    String? mobileNumber,
    String? address,
    String? cityStatePin,
    String? emergencyContact,
    String? educationalQualification,
    String? collegeUniversity,
    String? yearOfGraduation,
    String? currentStatus,
    String? currentOrganization,
    String? totalExperience,
    String? businessName,
    String? areasOfInterest,
    String? whyJoinProgram,
    String? businessIdea,
    String? skillsToDevelop,
    String? howHeardAboutProgram,
    String? documentsEnclosed,
    String? declaration,
    String? signature,
    String? declarationDate,
    String? paymentPlan,
    int? paidInstallments,
  }) {
    return StudentUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      courseId: courseId ?? this.courseId,
      fullName: fullName ?? this.fullName,
      passportPhotoUrl: passportPhotoUrl ?? this.passportPhotoUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      address: address ?? this.address,
      cityStatePin: cityStatePin ?? this.cityStatePin,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      educationalQualification: educationalQualification ?? this.educationalQualification,
      collegeUniversity: collegeUniversity ?? this.collegeUniversity,
      yearOfGraduation: yearOfGraduation ?? this.yearOfGraduation,
      currentStatus: currentStatus ?? this.currentStatus,
      currentOrganization: currentOrganization ?? this.currentOrganization,
      totalExperience: totalExperience ?? this.totalExperience,
      businessName: businessName ?? this.businessName,
      areasOfInterest: areasOfInterest ?? this.areasOfInterest,
      whyJoinProgram: whyJoinProgram ?? this.whyJoinProgram,
      businessIdea: businessIdea ?? this.businessIdea,
      skillsToDevelop: skillsToDevelop ?? this.skillsToDevelop,
      howHeardAboutProgram: howHeardAboutProgram ?? this.howHeardAboutProgram,
      documentsEnclosed: documentsEnclosed ?? this.documentsEnclosed,
      declaration: declaration ?? this.declaration,
      signature: signature ?? this.signature,
      declarationDate: declarationDate ?? this.declarationDate,
      paymentPlan: paymentPlan ?? this.paymentPlan,
      paidInstallments: paidInstallments ?? this.paidInstallments,
    );
  }
}
