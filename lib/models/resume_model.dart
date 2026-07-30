// lib/models/resume_model.dart

class EduEntry {
  String deg, col, yr, grade, honors;
  EduEntry({this.deg='', this.col='', this.yr='', this.grade='', this.honors=''});
  Map<String,dynamic> toJson() => {'deg':deg,'col':col,'yr':yr,'grade':grade,'honors':honors};
}

class WorkEntry {
  String co, des, start, end, loc, pts;
  WorkEntry({this.co='', this.des='', this.start='', this.end='Present', this.loc='', this.pts=''});
  Map<String,dynamic> toJson() => {'co':co,'des':des,'start':start,'end':end,'loc':loc,'pts':pts};
}

class ProjectEntry {
  String name, tech, desc;
  ProjectEntry({this.name='', this.tech='', this.desc=''});
  Map<String,dynamic> toJson() => {'name':name,'tech':tech,'desc':desc};
}

class SkillsData {
  String tech, soft, lang, cert;
  SkillsData({this.tech='', this.soft='', this.lang='', this.cert=''});
  Map<String,dynamic> toJson() => {'tech':tech,'soft':soft,'lang':lang,'cert':cert};
}

class ResumeRequest {
  String name, phone, email, city, linkedin, github;
  String role, industry, ctc, summary;
  int exp;
  List<EduEntry> edus;
  List<WorkEntry> works;
  SkillsData skills;
  List<ProjectEntry> projs;
  String extra;

  ResumeRequest({
    this.name='', this.phone='', this.email='', this.city='',
    this.linkedin='', this.github='', this.role='', this.industry='',
    this.ctc='', this.summary='', this.exp=0,
    List<EduEntry>? edus, List<WorkEntry>? works,
    SkillsData? skills, List<ProjectEntry>? projs, this.extra='',
  }) : edus = edus ?? [EduEntry()],
       works = works ?? [WorkEntry()],
       skills = skills ?? SkillsData(),
       projs = projs ?? [ProjectEntry()];

  Map<String,dynamic> toJson() => {
    'name':name,'phone':phone,'email':email,'city':city,
    'linkedin':linkedin,'github':github,'role':role,'industry':industry,
    'ctc':ctc,'summary':summary,'exp':exp,
    'edus': edus.map((e)=>e.toJson()).toList(),
    'works': works.map((w)=>w.toJson()).toList(),
    'skills': skills.toJson(),
    'projs': projs.map((p)=>p.toJson()).toList(),
    'extra': extra,
  };
}

class ResumeData {
  Map<String,dynamic> personal;
  String summary;
  List<dynamic> education;
  List<dynamic> experience;
  Map<String,dynamic> skills;
  List<dynamic> projects;
  List<dynamic> extra;
  List<dynamic> atsKeywords;
  int atsScore;
  int? jdMatchScore;
  List<dynamic> jdKeywordsMatched;
  List<dynamic> jdKeywordsMissing;
  Map<String,dynamic> extraUnknownFields;

  ResumeData({
    required this.personal, required this.summary,
    required this.education, required this.experience,
    required this.skills, required this.projects,
    required this.extra, required this.atsKeywords,
    this.atsScore = 90,
    this.jdMatchScore,
    this.jdKeywordsMatched = const [],
    this.jdKeywordsMissing = const [],
    Map<String,dynamic>? extraUnknownFields,
  }) : extraUnknownFields = extraUnknownFields ?? {};

  factory ResumeData.fromJson(Map<String,dynamic> j) {
    const knownKeys = {
      'personal', 'summary', 'education', 'experience', 'skills',
      'projects', 'extra', 'ats_keywords', 'ats_score', 'jd_match_score',
      'jd_keywords_matched', 'jd_keywords_missing'
    };
    final unknown = <String, dynamic>{};
    j.forEach((key, value) {
      if (!knownKeys.contains(key)) {
        unknown[key] = value;
      }
    });

    return ResumeData(
      personal: Map<String,dynamic>.from(j['personal'] ?? {}),
      summary: j['summary'] ?? '',
      education: List<dynamic>.from(j['education'] ?? []),
      experience: List<dynamic>.from(j['experience'] ?? []),
      skills: Map<String,dynamic>.from(j['skills'] ?? {}),
      projects: List<dynamic>.from(j['projects'] ?? []),
      extra: List<dynamic>.from(j['extra'] ?? []),
      atsKeywords: List<dynamic>.from(j['ats_keywords'] ?? []),
      atsScore: j['ats_score'] ?? 90,
      jdMatchScore: j['jd_match_score'],
      jdKeywordsMatched: List<dynamic>.from(j['jd_keywords_matched'] ?? []),
      jdKeywordsMissing: List<dynamic>.from(j['jd_keywords_missing'] ?? []),
      extraUnknownFields: unknown,
    );
  }

  Map<String,dynamic> toJson() {
    final map = <String,dynamic>{
      'personal': personal,
      'summary': summary,
      'education': education,
      'experience': experience,
      'skills': skills,
      'projects': projects,
      'extra': extra,
      'ats_keywords': atsKeywords,
      'ats_score': atsScore,
      'jd_match_score': jdMatchScore,
      'jd_keywords_matched': jdKeywordsMatched,
      'jd_keywords_missing': jdKeywordsMissing,
    };
    map.addAll(extraUnknownFields);
    return map;
  }
}
