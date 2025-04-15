const List<String> contactKeywords = [
  '📍',
  '📞',
  '📧',
  '🔗',
  '☎️',
  '📠',
  '📡',
  '✉️',
  '📩',
  '🏠',
  '🗺️',
  '🔗',
  '🌍',
  'contact',
  'contacts',
  'contact information',
  'phone',
  'telephone',
  'mobile',
  'email',
  'e-mail',
  'mail',
  'address',
  'location',
  'city',
  'residence',
  'linkedin',
  'portfolio',
  'website',
  'github',
  'twitter',
  'blog',
  'socials',
  'skype',
  'whatsapp',
  'telegram',
  'discord',
  'slack'
];

const List<String> workExperienceKeywords = [
  'work experience',
  'experience',
  'professional experience',
  'employment history',
  'career history',
  'job history',
  'relevant experience',
  'work background',
  'positions held',
  'roles & responsibilities',
  'projects & roles',
  'freelance work',
  'internships',
  'employment',
  'job experience',
  'industry experience'
];

const List<String> educationKeywords = [
  'education',
];

const List<String> skillsKeywords = [
  'skills',
  'core skills',
  'technical skills',
  'competencies',
  'abilities',
  'strengths',
  'expertise',
  'proficiencies',
  'capabilities',
  'key skills',
  'specialties',
  'skill set',
  'soft skills',
  'hard skills',
  'software proficiency',
  'programming languages',
  'frameworks',
  'tools & technologies',
  'certifications & skills'
];

const List<String> projectsKeywords = [
  'projects',
  'notable projects',
  'portfolio',
  'work samples',
  'case studies',
  'achievements',
  'personal projects',
  'client projects',
  'freelance projects',
  'side projects',
  'independent work',
  'team projects',
  'contributions',
  'open source',
  'github projects'
];

const List<String> certificationsKeywords = [
  'certifications',
  'certificates',
  'licenses',
  'accreditations',
  'training',
  'professional development',
  'courses',
  'completed courses',
  'online courses',
  'specializations',
  'workshops'
];

// bool containsAnyKeyword(String? text, List<String> keywords) {
//   if (text == null) return false;
//   return keywords.any((keyword) => text.toLowerCase().contains(keyword));
// }

bool equalsKeyword(String? text, List<String> keywords) {
  if (text == null) return false;
  return keywords
      .any((keyword) => keyword.startsWith(text.trim().toLowerCase()));
}
