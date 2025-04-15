// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class CVFilters extends Equatable {
  const CVFilters({
    required this.name,
    required this.contacts,
    required this.workExperience,
    required this.education,
    required this.skills,
    required this.projects,
    required this.certifications,
  });

  factory CVFilters.empty() => const CVFilters(
        name: '',
        contacts: [],
        workExperience: [],
        education: [],
        skills: [],
        projects: [],
        certifications: [],
      );

  final String name;
  final List<String> contacts;
  final List<String> workExperience;
  final List<String> education;
  final List<String> skills;
  final List<String> projects;
  final List<String> certifications;

  CVFilters copyWith({
    String? name,
    List<String>? contacts,
    List<String>? workExperience,
    List<String>? education,
    List<String>? skills,
    List<String>? projects,
    List<String>? certifications,
  }) {
    return CVFilters(
      name: name ?? this.name,
      contacts: contacts ?? this.contacts,
      workExperience: workExperience ?? this.workExperience,
      education: education ?? this.education,
      skills: skills ?? this.skills,
      projects: projects ?? this.projects,
      certifications: certifications ?? this.certifications,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'contacts': contacts,
      'workExperience': workExperience,
      'education': education,
      'skills': skills,
      'projects': projects,
      'certifications': certifications,
    };
  }

  factory CVFilters.fromMap(Map<String, dynamic> map) {
    return CVFilters(
      name: map['name'] as String,
      contacts: List<String>.from(map['contacts'] as List<String>),
      workExperience: List<String>.from(map['workExperience'] as List<String>),
      education: List<String>.from(map['education'] as List<String>),
      skills: List<String>.from(map['skills'] as List<String>),
      projects: List<String>.from(map['projects'] as List<String>),
      certifications: List<String>.from(map['certifications'] as List<String>),
    );
  }

  // @override
  // String toString() {
  //   return '''CVFilters(name: $name, contacts: $contacts, workExperience: $workExperience, education: $education, skills: $skills, projects: $projects, certifications: $certifications)''';
  // }

  @override
  List<Object> get props {
    return [
      name,
      contacts,
      workExperience,
      education,
      skills,
      projects,
      certifications,
    ];
  }
}

class WorkFilter extends Equatable {
  const WorkFilter({
    required this.title,
    required this.location,
    required this.salary,
    required this.jobType,
    required this.overview,
    required this.responsibility,
    required this.requirements,
    required this.benefit,
    required this.howToApply,
  });

  factory WorkFilter.empty() => const WorkFilter(
        title: '',
        location: '',
        salary: '',
        jobType: '',
        overview: '',
        howToApply: '',
        benefit: [],
        requirements: [],
        responsibility: [],
      );

  final String title;
  final String location;
  final String salary;
  final String jobType;
  final String overview;
  final List<String> responsibility;
  final List<String> requirements;
  final List<String> benefit;
  final String howToApply;

  WorkFilter copyWith({
    String? title,
    String? location,
    String? salary,
    String? jobType,
    String? overview,
    List<String>? responsibility,
    List<String>? requirements,
    List<String>? benefit,
    String? howToApply,
  }) {
    return WorkFilter(
      title: title ?? this.title,
      location: location ?? this.location,
      salary: salary ?? this.salary,
      jobType: jobType ?? this.jobType,
      overview: overview ?? this.overview,
      responsibility: responsibility ?? this.responsibility,
      requirements: requirements ?? this.requirements,
      benefit: benefit ?? this.benefit,
      howToApply: howToApply ?? this.howToApply,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'location': location,
      'salary': salary,
      'jobType': jobType,
      'overview': overview,
      'responsibility': responsibility,
      'requirements': requirements,
      'benefit': benefit,
      'howToApply': howToApply,
    };
  }

  factory WorkFilter.fromMap(Map<String, dynamic> map) {
    return WorkFilter(
      title: map['title'] as String,
      location: map['location'] as String,
      salary: map['salary'] as String,
      jobType: map['jobType'] as String,
      overview: map['overview'] as String,
      responsibility: List<String>.from(map['responsibility'] as List<String>),
      requirements: List<String>.from(map['requirements'] as List<String>),
      benefit: List<String>.from(map['benefit'] as List<String>),
      howToApply: map['howToApply'] as String,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      title,
      location,
      salary,
      jobType,
      overview,
      responsibility,
      requirements,
      benefit,
      howToApply,
    ];
  }
}
