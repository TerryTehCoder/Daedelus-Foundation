import React from 'react';

import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Flex,
  Grid,
  Icon,
  Modal,
  ProgressBar,
  Section,
  Table,
} from '../components';
import { Window } from '../layouts';

export const PersistenceMasterPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const [activeTab, setActiveTab] = React.useState('desktop');
  const [facilityActiveTab, setFacilityActiveTab] = React.useState('overview');
  const [scpActiveTab, setScpActiveTab] = React.useState('overview');
  const [techActiveTab, setTechActiveTab] = React.useState('overview');
  const [medicalActiveTab, setMedicalActiveTab] = React.useState('overview');
  const [securityActiveTab, setSecurityActiveTab] = React.useState('overview');
  const [researchActiveTab, setResearchActiveTab] = React.useState('overview');
  const [personnelActiveTab, setPersonnelActiveTab] =
    React.useState('overview');
  const [playerActiveTab, setPlayerActiveTab] = React.useState('overview');

  const [infrastructureActiveTab, setInfrastructureActiveTab] =
    React.useState('overview');
  const [analyticsActiveTab, setAnalyticsActiveTab] =
    React.useState('overview');
  const [scipnetCollapsed, setScipnetCollapsed] = React.useState(false);

  // Notification system state
  const [notificationsOpen, setNotificationsOpen] = React.useState(false);
  const [notificationCount, setNotificationCount] = React.useState(0);
  const [notificationHistory, setNotificationHistory] = React.useState([]);
  const [notificationSettings, setNotificationSettings] = React.useState({
    sound: true,
    desktop: true,
    autoHide: true,
    maxNotifications: 50,
  });

  // Search system state
  const [searchOpen, setSearchOpen] = React.useState(false);
  const [searchTerm, setSearchTerm] = React.useState('');
  const [searchResults, setSearchResults] = React.useState([]);
  const [searchCategory, setSearchCategory] = React.useState('all');

  // Theme system state
  const [currentTheme, setCurrentTheme] = React.useState('dark');
  const [themeOpen, setThemeOpen] = React.useState(false);

  // Research modal state
  const [researchModalOpen, setResearchModalOpen] = React.useState(false);
  const [researchFormData, setResearchFormData] = React.useState({
    title: '',
    description: '',
    category: 'general',
    priority: 'medium',
    lead_researcher: '',
    budget: '',
    timeline: '',
    objectives: '',
    methodology: '',
    expected_outcomes: '',
    risks: '',
    approvals: [],
    status: 'pending',
    progress: 0,
    start_date: '',
    end_date: '',
    team_members: [],
    equipment_needed: [],
    funding_source: '',
    security_clearance: 'level_1',
    containment_requirements: '',
    ethical_approval: false,
    safety_protocols: '',
  });

  // SCP modal state
  const [scpModalOpen, setScpModalOpen] = React.useState(false);
  const [scpFormData, setScpFormData] = React.useState({
    designation: '',
    name: '',
    object_class: 'safe',
    threat_level: 'green',
    description: '',
    containment_procedures: '',
    special_containment_procedures: '',
    description_2: '',
    addenda: '',
    incident_reports: [],
    testing_logs: [],
    personnel_assignments: [],
    location: '',
    discovery_date: '',
    discovery_location: '',
    original_containment: '',
    current_status: 'contained',
    containment_breaches: 0,
    last_incident: '',
    research_clearance: 'level_1',
    testing_authorized: false,
    cross_testing: [],
    related_scps: [],
    anomalous_properties: '',
    recovery_notes: '',
    classification_notes: '',
    security_clearance: 'level_1',
    containment_cost: '',
    maintenance_schedule: '',
    monitoring_equipment: [],
    emergency_protocols: '',
    termination_attempts: [],
    containment_effectiveness: 100,
    risk_assessment: '',
    personnel_requirements: '',
    facility_requirements: '',
    budget_allocation: '',
    research_priorities: [],
    containment_upgrades: [],
    incident_history: [],
    testing_protocols: '',
    cross_references: [],
    classification_review_date: '',
    containment_review_date: '',
    security_audit_date: '',
    last_containment_test: '',
    next_containment_test: '',
    containment_rating: 'stable',
    threat_assessment: 'low',
    containment_priority: 'standard',
    research_priority: 'standard',
    security_priority: 'standard',
    maintenance_priority: 'standard',
    testing_priority: 'standard',
    monitoring_priority: 'standard',
    emergency_priority: 'standard',
    termination_priority: 'none',
    classification_priority: 'standard',
    containment_priority_level: 'standard',
    research_priority_level: 'standard',
    security_priority_level: 'standard',
    maintenance_priority_level: 'standard',
    testing_priority_level: 'standard',
    monitoring_priority_level: 'standard',
    emergency_priority_level: 'standard',
    termination_priority_level: 'none',
    classification_priority_level: 'standard',
  });

  // Medical modal state
  const [medicalModalOpen, setMedicalModalOpen] = React.useState(false);
  const [medicalFormData, setMedicalFormData] = React.useState({
    patient_id: '',
    patient_name: '',
    age: '',
    gender: '',
    blood_type: '',
    medical_history: '',
    current_condition: '',
    symptoms: '',
    diagnosis: '',
    treatment_plan: '',
    medications: [],
    allergies: [],
    vital_signs: {
      temperature: '',
      blood_pressure: '',
      heart_rate: '',
      respiratory_rate: '',
      oxygen_saturation: '',
    },
    lab_results: [],
    imaging_results: [],
    procedures: [],
    notes: '',
    attending_physician: '',
    department: '',
    admission_date: '',
    discharge_date: '',
    room_number: '',
    emergency_contact: '',
    insurance_info: '',
    next_of_kin: '',
    special_instructions: '',
    quarantine_status: false,
    isolation_level: 'none',
    infectious_disease: false,
    disease_type: '',
    containment_required: false,
    containment_level: 'none',
    security_clearance: 'level_1',
    research_subject: false,
    research_protocol: '',
    experimental_treatment: false,
    treatment_consent: false,
    family_consent: false,
    legal_guardian: '',
    power_of_attorney: '',
    do_not_resuscitate: false,
    living_will: false,
    organ_donor: false,
    autopsy_authorized: false,
    research_authorized: false,
    experimental_authorized: false,
    testing_authorized: false,
    monitoring_authorized: false,
    isolation_authorized: false,
    quarantine_authorized: false,
    containment_authorized: false,
    security_authorized: false,
    research_priority: 'standard',
    treatment_priority: 'standard',
    monitoring_priority: 'standard',
    security_priority: 'standard',
    containment_priority: 'standard',
    isolation_priority: 'standard',
    quarantine_priority: 'standard',
    testing_priority: 'standard',
    autopsy_priority: 'none',
    research_priority_level: 'standard',
    treatment_priority_level: 'standard',
    monitoring_priority_level: 'standard',
    security_priority_level: 'standard',
    containment_priority_level: 'standard',
    isolation_priority_level: 'standard',
    quarantine_priority_level: 'standard',
    testing_priority_level: 'standard',
    autopsy_priority_level: 'none',
  });

  // Security modal state
  const [securityModalOpen, setSecurityModalOpen] = React.useState(false);
  const [securityFormData, setSecurityFormData] = React.useState({
    incident_id: '',
    incident_type: 'breach',
    severity: 'low',
    location: '',
    date_time: '',
    description: '',
    involved_personnel: [],
    involved_scps: [],
    casualties: {
      fatalities: 0,
      injuries: 0,
      missing: 0,
    },
    containment_status: 'contained',
    threat_level: 'green',
    response_team: '',
    response_time: '',
    containment_time: '',
    investigation_status: 'pending',
    investigation_lead: '',
    evidence_collected: [],
    witnesses: [],
    security_breaches: [],
    system_failures: [],
    human_errors: [],
    external_threats: [],
    internal_threats: [],
    anomalous_events: [],
    containment_failures: [],
    security_failures: [],
    procedural_violations: [],
    equipment_failures: [],
    communication_failures: [],
    coordination_failures: [],
    response_delays: [],
    investigation_findings: '',
    corrective_actions: [],
    preventive_measures: [],
    security_upgrades: [],
    personnel_training: [],
    protocol_revisions: [],
    equipment_upgrades: [],
    system_upgrades: [],
    facility_upgrades: [],
    containment_upgrades: [],
    monitoring_upgrades: [],
    response_upgrades: [],
    investigation_upgrades: [],
    security_audit: false,
    security_review: false,
    security_assessment: false,
    security_evaluation: false,
    security_inspection: false,
    security_testing: false,
    security_monitoring: false,
    security_tracking: false,
    security_reporting: false,
    security_documentation: false,
    security_analysis: false,
    security_planning: false,
    security_coordination: false,
    security_communication: false,
    security_training: false,
    security_awareness: false,
    security_preparedness: false,
    security_response: false,
    security_recovery: false,
    security_lessons: false,
    security_improvements: false,
    security_enhancements: false,
    security_optimization: false,
    security_modernization: false,
    security_innovation: false,
    security_development: false,
    security_research: false,
    security_testing_protocols: false,
    security_monitoring_protocols: false,
    security_response_protocols: false,
    security_investigation_protocols: false,
    security_documentation_protocols: false,
    security_analysis_protocols: false,
    security_planning_protocols: false,
    security_coordination_protocols: false,
    security_communication_protocols: false,
    security_training_protocols: false,
    security_awareness_protocols: false,
    security_preparedness_protocols: false,
    security_recovery_protocols: false,
    security_lessons_protocols: false,
    security_improvements_protocols: false,
    security_enhancements_protocols: false,
    security_optimization_protocols: false,
    security_modernization_protocols: false,
    security_innovation_protocols: false,
    security_development_protocols: false,
    security_research_protocols: false,
  });

  // Personnel modal state
  const [personnelModalOpen, setPersonnelModalOpen] = React.useState(false);
  const [personnelFormData, setPersonnelFormData] = React.useState({
    employee_id: '',
    name: '',
    position: '',
    department: '',
    security_clearance: 'level_1',
    access_level: 'basic',
    hire_date: '',
    supervisor: '',
    contact_info: {
      phone: '',
      email: '',
      emergency_contact: '',
    },
    qualifications: [],
    certifications: [],
    training_completed: [],
    performance_rating: 'satisfactory',
    status: 'active',
    location: '',
    schedule: '',
    salary: '',
    benefits: [],
    medical_clearance: false,
    psychological_clearance: false,
    background_check: false,
    drug_test: false,
    polygraph_test: false,
    security_interview: false,
    clearance_review_date: '',
    next_review_date: '',
    incident_history: [],
    commendations: [],
    disciplinary_actions: [],
    assignments: [],
    projects: [],
    skills: [],
    languages: [],
    equipment_authorized: [],
    facility_access: [],
    system_access: [],
    clearance_level: 'level_1',
    clearance_type: 'standard',
    clearance_status: 'active',
    clearance_expiry: '',
    clearance_renewal: '',
    clearance_conditions: [],
    clearance_restrictions: [],
    clearance_notes: '',
    security_briefing: false,
    security_training: false,
    security_awareness: false,
    security_compliance: false,
    security_audit: false,
    security_review: false,
    security_assessment: false,
    security_evaluation: false,
    security_inspection: false,
    security_testing: false,
    security_monitoring: false,
    security_tracking: false,
    security_reporting: false,
    security_documentation: false,
    security_analysis: false,
    security_planning: false,
    security_coordination: false,
    security_communication: false,
    security_training_completed: false,
    security_awareness_completed: false,
    security_preparedness: false,
    security_response: false,
    security_recovery: false,
    security_lessons: false,
    security_improvements: false,
    security_enhancements: false,
    security_optimization: false,
    security_modernization: false,
    security_innovation: false,
    security_development: false,
    security_research: false,
  });

  // Technology modal state
  const [technologyModalOpen, setTechnologyModalOpen] = React.useState(false);
  const [technologyFormData, setTechnologyFormData] = React.useState({
    device_id: '',
    device_name: '',
    device_type: 'computer',
    manufacturer: '',
    model: '',
    serial_number: '',
    location: '',
    assigned_to: '',
    department: '',
    status: 'operational',
    purchase_date: '',
    warranty_expiry: '',
    last_maintenance: '',
    next_maintenance: '',
    specifications: {
      processor: '',
      memory: '',
      storage: '',
      network: '',
      os: '',
    },
    software_installed: [],
    security_software: [],
    access_controls: [],
    monitoring_systems: [],
    backup_systems: [],
    redundancy_systems: [],
    failover_systems: [],
    disaster_recovery: [],
    maintenance_schedule: '',
    maintenance_history: [],
    repair_history: [],
    upgrade_history: [],
    replacement_history: [],
    cost_information: {
      purchase_cost: '',
      maintenance_cost: '',
      operational_cost: '',
      replacement_cost: '',
    },
    performance_metrics: {
      uptime: '',
      response_time: '',
      throughput: '',
      efficiency: '',
    },
    security_features: [],
    vulnerabilities: [],
    patches_installed: [],
    updates_pending: [],
    compliance_status: 'compliant',
    audit_status: 'passed',
    certification_status: 'certified',
    testing_status: 'passed',
    monitoring_status: 'active',
    tracking_status: 'active',
    reporting_status: 'active',
    documentation_status: 'complete',
    analysis_status: 'complete',
    planning_status: 'complete',
    coordination_status: 'complete',
    communication_status: 'active',
    training_status: 'complete',
    awareness_status: 'complete',
    preparedness_status: 'complete',
    response_status: 'ready',
    recovery_status: 'ready',
    lessons_status: 'complete',
    improvements_status: 'complete',
    enhancements_status: 'complete',
    optimization_status: 'complete',
    modernization_status: 'complete',
    innovation_status: 'complete',
    development_status: 'complete',
    research_status: 'complete',
  });

  // Analytics Report modal state
  const [analyticsReportModalOpen, setAnalyticsReportModalOpen] =
    React.useState(false);
  const [analyticsReportFormData, setAnalyticsReportFormData] = React.useState({
    report_id: '',
    report_title: '',
    report_type: 'performance',
    date_range: {
      start_date: '',
      end_date: '',
    },
    metrics_included: {
      performance_metrics: true,
      efficiency_data: true,
      trend_analysis: true,
      comparative_data: true,
      predictive_analytics: true,
      statistical_summary: true,
    },
    data_sources: [],
    filters: {
      department: 'all',
      facility: 'all',
      time_period: 'monthly',
      data_quality: 'all',
    },
    format: 'pdf',
    delivery_method: 'download',
    recipients: [],
    custom_parameters: {
      confidence_level: '95',
      significance_level: '0.05',
      sample_size: 'auto',
      outlier_detection: true,
      trend_forecasting: true,
    },
    visualization_options: {
      charts: true,
      graphs: true,
      tables: true,
      heatmaps: true,
      dashboards: true,
    },
    analysis_depth: 'comprehensive',
    priority: 'normal',
    notes: '',
  });

  // Analytics KPI Dashboard modal state
  const [analyticsKpiModalOpen, setAnalyticsKpiModalOpen] =
    React.useState(false);
  const [analyticsKpiFormData, setAnalyticsKpiFormData] = React.useState({
    dashboard_id: '',
    dashboard_name: '',
    dashboard_type: 'executive',
    kpi_categories: {
      performance: {
        overall_efficiency: true,
        response_time: true,
        throughput: true,
        accuracy: true,
        reliability: true,
      },
      operational: {
        uptime: true,
        maintenance_schedule: true,
        resource_utilization: true,
        cost_efficiency: true,
        quality_metrics: true,
      },
      security: {
        incident_rate: true,
        response_time: true,
        compliance_score: true,
        threat_level: true,
        vulnerability_status: true,
      },
      research: {
        project_completion: true,
        innovation_index: true,
        publication_rate: true,
        collaboration_score: true,
        breakthrough_metrics: true,
      },
      personnel: {
        productivity: true,
        training_completion: true,
        satisfaction_score: true,
        retention_rate: true,
        performance_rating: true,
      },
    },
    refresh_rate: 'real_time',
    display_options: {
      theme: 'dark',
      layout: 'grid',
      animations: true,
      interactive: true,
      alerts: true,
    },
    thresholds: {
      warning_level: '75',
      critical_level: '90',
      target_level: '85',
    },
    data_sources: [],
    custom_widgets: [],
    sharing_settings: {
      public_access: false,
      authorized_users: [],
      export_permissions: true,
    },
  });

  // Security Personnel Management modal state
  const [securityPersonnelModalOpen, setSecurityPersonnelModalOpen] =
    React.useState(false);
  const [securityPersonnelFormData, setSecurityPersonnelFormData] =
    React.useState({
      operation_id: '',
      operation_type: 'personnel_management',
      personnel_data: {
        total_personnel: '',
        active_personnel: '',
        on_duty: '',
        off_duty: '',
        training: '',
        leave: '',
        suspended: '',
      },
      assignments: {
        patrol_assignments: [],
        post_assignments: [],
        special_assignments: [],
        emergency_assignments: [],
      },
      qualifications: {
        firearms_certified: [],
        taser_certified: [],
        medical_trained: [],
        tactical_trained: [],
        investigation_trained: [],
      },
      performance_metrics: {
        response_time: '',
        incident_resolution: '',
        community_relations: '',
        training_completion: '',
        disciplinary_actions: '',
      },
      scheduling: {
        shift_patterns: [],
        overtime_hours: '',
        vacation_requests: [],
        sick_leave: [],
      },
      equipment: {
        firearms_assigned: [],
        body_armor: [],
        communication_devices: [],
        vehicles: [],
      },
      training_schedule: [],
      evaluation_dates: [],
      clearance_levels: [],
      notes: '',
    });

  // Security Logs modal state
  const [securityLogsModalOpen, setSecurityLogsModalOpen] =
    React.useState(false);
  const [securityLogsFormData, setSecurityLogsFormData] = React.useState({
    log_id: '',
    log_type: 'security',
    date_range: {
      start_date: '',
      end_date: '',
    },
    log_categories: {
      access_logs: true,
      incident_logs: true,
      personnel_logs: true,
      system_logs: true,
      alert_logs: true,
      maintenance_logs: true,
    },
    filters: {
      severity: 'all',
      personnel: 'all',
      location: 'all',
      incident_type: 'all',
    },
    search_terms: [],
    export_format: 'csv',
    include_details: true,
    include_metadata: true,
    sort_by: 'timestamp',
    sort_order: 'descending',
    max_results: '1000',
    real_time_monitoring: false,
    alert_thresholds: {
      critical_incidents: '5',
      failed_access: '10',
      system_errors: '20',
    },
  });

  // Security Scan modal state
  const [securityScanModalOpen, setSecurityScanModalOpen] =
    React.useState(false);
  const [securityScanFormData, setSecurityScanFormData] = React.useState({
    scan_id: '',
    scan_type: 'comprehensive',
    target_systems: {
      access_control: true,
      surveillance: true,
      communications: true,
      databases: true,
      networks: true,
      physical_security: true,
    },
    scan_parameters: {
      depth: 'thorough',
      speed: 'balanced',
      stealth: false,
      real_time: true,
    },
    vulnerability_assessment: {
      critical_vulnerabilities: true,
      high_priority: true,
      medium_priority: true,
      low_priority: false,
      informational: false,
    },
    threat_detection: {
      malware_scan: true,
      intrusion_detection: true,
      anomaly_detection: true,
      behavioral_analysis: true,
      signature_matching: true,
    },
    physical_security: {
      door_integrity: true,
      camera_systems: true,
      alarm_systems: true,
      environmental_monitoring: true,
      perimeter_security: true,
    },
    reporting: {
      generate_report: true,
      alert_authorities: true,
      log_findings: true,
      create_tickets: true,
    },
    scan_schedule: {
      immediate: true,
      scheduled: false,
      recurring: false,
    },
  });

  // Security Access Control modal state
  const [securityAccessModalOpen, setSecurityAccessModalOpen] =
    React.useState(false);
  const [securityAccessFormData, setSecurityAccessFormData] = React.useState({
    access_id: '',
    access_type: 'system_management',
    access_levels: {
      level_1: {
        name: 'Basic Access',
        permissions: {
          view_logs: true,
          basic_reports: true,
          self_service: true,
        },
        restrictions: [],
      },
      level_2: {
        name: 'Supervisor Access',
        permissions: {
          view_logs: true,
          basic_reports: true,
          personnel_management: true,
          incident_reports: true,
          basic_analytics: true,
        },
        restrictions: [],
      },
      level_3: {
        name: 'Manager Access',
        permissions: {
          view_logs: true,
          all_reports: true,
          personnel_management: true,
          incident_management: true,
          system_configuration: true,
          analytics: true,
        },
        restrictions: [],
      },
      level_4: {
        name: 'Administrator Access',
        permissions: {
          all_permissions: true,
        },
        restrictions: [],
      },
    },
    user_management: {
      add_users: true,
      remove_users: true,
      modify_permissions: true,
      bulk_operations: true,
    },
    authentication: {
      password_policy: {
        min_length: '12',
        complexity: 'high',
        expiration_days: '90',
        history_count: '5',
      },
      multi_factor: {
        enabled: true,
        methods: ['sms', 'email', 'authenticator'],
        backup_codes: true,
      },
      session_management: {
        timeout_minutes: '30',
        concurrent_sessions: '2',
        ip_restrictions: true,
      },
    },
    access_points: {
      doors: [],
      elevators: [],
      restricted_areas: [],
      systems: [],
      networks: [],
    },
    monitoring: {
      real_time_monitoring: true,
      access_logs: true,
      failed_attempts: true,
      unusual_patterns: true,
      alerts: true,
    },
    emergency_protocols: {
      lockdown_procedures: [],
      emergency_access: [],
      override_protocols: [],
      backup_systems: [],
    },
  });

  // Budget Management State
  const [budgetModal, setBudgetModal] = React.useState(false);
  const [budgetRequestModal, setBudgetRequestModal] = React.useState(false);
  const [budgetTransferModal, setBudgetTransferModal] = React.useState(false);
  const [budgetReportModal, setBudgetReportModal] = React.useState(false);
  const [budgetFormData, setBudgetFormData] = React.useState({
    department_id: 'supply',
    amount: '',
    category: 'equipment',
    description: '',
    transaction_type: 'EXPENSE',
  });
  const [budgetRequestData, setBudgetRequestData] = React.useState({
    department_id: 'supply',
    requested_amount: '',
    requested_category: 'equipment',
    justification: '',
    priority: 1,
  });
  const [budgetTransferData, setBudgetTransferData] = React.useState({
    from_department: 'supply',
    to_department: 'security',
    amount: '',
    reason: '',
  });

  // Facility modal state
  const [facilityModalOpen, setFacilityModalOpen] = React.useState(false);
  const [facilityFormData, setFacilityFormData] = React.useState({
    facility_id: '',
    facility_name: '',
    facility_type: 'site',
    location: {
      address: '',
      city: '',
      state: '',
      country: '',
      coordinates: '',
    },
    capacity: {
      personnel: '',
      equipment: '',
      storage: '',
      containment: '',
    },
    status: 'operational',
    security_level: 'level_1',
    containment_level: 'level_1',
    construction_date: '',
    last_renovation: '',
    next_renovation: '',
    departments: [],
    personnel_assigned: [],
    equipment_installed: [],
    systems_installed: [],
    security_systems: [],
    containment_systems: [],
    monitoring_systems: [],
    communication_systems: [],
    power_systems: [],
    environmental_systems: [],
    maintenance_systems: [],
    backup_systems: [],
    emergency_systems: [],
    safety_systems: [],
    fire_suppression: [],
    ventilation_systems: [],
    water_systems: [],
    waste_systems: [],
    telecommunications: [],
    data_systems: [],
    laboratory_systems: [],
    medical_systems: [],
    research_systems: [],
    administrative_systems: [],
    operational_systems: [],
    logistical_systems: [],
    transportation_systems: [],
    storage_systems: [],
    archival_systems: [],
    security_clearance: 'level_1',
    access_controls: [],
    monitoring_equipment: [],
    surveillance_systems: [],
    alarm_systems: [],
    response_systems: [],
    emergency_protocols: [],
    evacuation_procedures: [],
    lockdown_procedures: [],
    containment_procedures: [],
    security_procedures: [],
    safety_procedures: [],
    maintenance_procedures: [],
    operational_procedures: [],
    administrative_procedures: [],
    logistical_procedures: [],
    transportation_procedures: [],
    storage_procedures: [],
    archival_procedures: [],
    compliance_status: 'compliant',
    audit_status: 'passed',
    certification_status: 'certified',
    testing_status: 'passed',
    monitoring_status: 'active',
    tracking_status: 'active',
    reporting_status: 'active',
    documentation_status: 'complete',
    analysis_status: 'complete',
    planning_status: 'complete',
    coordination_status: 'complete',
    communication_status: 'active',
    training_status: 'complete',
    awareness_status: 'complete',
    preparedness_status: 'complete',
    response_status: 'ready',
    recovery_status: 'ready',
    lessons_status: 'complete',
    improvements_status: 'complete',
    enhancements_status: 'complete',
    optimization_status: 'complete',
    modernization_status: 'complete',
    innovation_status: 'complete',
    development_status: 'complete',
    research_status: 'complete',
  });

  // Debug activeTab changes and add test notifications
  React.useEffect(() => {
    console.log('activeTab changed to:', activeTab, 'type:', typeof activeTab);

    // Add test notifications for demonstration
    if (activeTab === 'desktop' && notificationHistory.length === 0) {
      setTimeout(
        () =>
          addNotification(
            'System Online',
            'All persistence systems are operational',
            'success',
          ),
        1000,
      );
      setTimeout(
        () =>
          addNotification(
            'Security Alert',
            'Unauthorized access attempt detected',
            'warning',
          ),
        3000,
      );
      setTimeout(
        () =>
          addNotification(
            'Medical Update',
            'Patient records synchronized successfully',
            'info',
          ),
        5000,
      );
    }
  }, [activeTab]);

  const {
    facility_data,
    scp_data,
    technology_data,
    medical_data,
    security_data,
    research_data,
    personnel_data,
    budget_data,
    player_data,
    system_status,
    analytics_data,
    infrastructure_data,

    notifications,
    personnel_details,
  } = data;

  // Legacy data status indicator (kept for compatibility)
  const DataStatusIndicator = ({ data, label }) => (
    <Box style={{ display: 'inline-block', marginLeft: '10px' }}>
      <Box
        style={{
          display: 'inline-block',
          width: '8px',
          height: '8px',
          borderRadius: '50%',
          backgroundColor: data ? '#00ff00' : '#ff0000',
          marginRight: '5px',
        }}
      />
      <Box style={{ fontSize: '10px', opacity: 0.7 }}>
        {label}: {data ? 'LIVE' : 'OFFLINE'}
      </Box>
    </Box>
  );

  // Enhanced uniform button component with maximum functionality
  const EnhancedButton = ({
    icon,
    children,
    onClick,
    color = 'default',
    disabled = false,
    loading = false,
    tooltip = '',
    compact = false,
    style = {},
  }) => {
    const [isHovered, setIsHovered] = React.useState(false);
    const [isPressed, setIsPressed] = React.useState(false);

    const handleClick = () => {
      if (!disabled && !loading) {
        setIsPressed(true);
        setTimeout(() => setIsPressed(false), 150);
        onClick();
      }
    };

    const baseStyle = {
      display: 'inline-flex',
      alignItems: 'center',
      gap: '6px',
      padding: compact ? '6px 12px' : '8px 16px',
      borderRadius: '4px',
      border: '1px solid',
      fontSize: compact ? '12px' : '14px',
      fontWeight: '500',
      cursor: disabled || loading ? 'not-allowed' : 'pointer',
      transition: 'all 0.2s ease',
      opacity: disabled ? 0.5 : 1,
      position: 'relative',
      overflow: 'hidden',
      ...style,
    };

    const colorStyles = {
      default: {
        background: isPressed
          ? 'rgba(255,255,255,0.2)'
          : isHovered
            ? 'rgba(255,255,255,0.1)'
            : 'rgba(255,255,255,0.05)',
        borderColor: 'rgba(255,255,255,0.3)',
        color: '#ffffff',
      },
      good: {
        background: isPressed
          ? 'rgba(0,255,0,0.3)'
          : isHovered
            ? 'rgba(0,255,0,0.2)'
            : 'rgba(0,255,0,0.1)',
        borderColor: 'rgba(0,255,0,0.5)',
        color: '#00ff00',
      },
      average: {
        background: isPressed
          ? 'rgba(255,165,0,0.3)'
          : isHovered
            ? 'rgba(255,165,0,0.2)'
            : 'rgba(255,165,0,0.1)',
        borderColor: 'rgba(255,165,0,0.5)',
        color: '#ffaa00',
      },
      bad: {
        background: isPressed
          ? 'rgba(255,0,0,0.3)'
          : isHovered
            ? 'rgba(255,0,0,0.2)'
            : 'rgba(255,0,0,0.1)',
        borderColor: 'rgba(255,0,0,0.5)',
        color: '#ff6666',
      },
      blue: {
        background: isPressed
          ? 'rgba(0,150,255,0.3)'
          : isHovered
            ? 'rgba(0,150,255,0.2)'
            : 'rgba(0,150,255,0.1)',
        borderColor: 'rgba(0,150,255,0.5)',
        color: '#66ccff',
      },
      purple: {
        background: isPressed
          ? 'rgba(150,0,255,0.3)'
          : isHovered
            ? 'rgba(150,0,255,0.2)'
            : 'rgba(150,0,255,0.1)',
        borderColor: 'rgba(150,0,255,0.5)',
        color: '#cc66ff',
      },
    };

    const buttonStyle = {
      ...baseStyle,
      ...(colorStyles[color] || colorStyles.default),
      transform: isPressed ? 'scale(0.95)' : 'scale(1)',
      boxShadow: isHovered ? '0 2px 8px rgba(0,0,0,0.3)' : 'none',
    };

    return (
      <Box
        style={buttonStyle}
        onClick={handleClick}
        onMouseEnter={() => setIsHovered(true)}
        onMouseLeave={() => setIsHovered(false)}
        title={tooltip}
      >
        {loading && (
          <Box
            style={{
              position: 'absolute',
              top: '50%',
              left: '50%',
              transform: 'translate(-50%, -50%)',
              width: '12px',
              height: '12px',
              border: '2px solid transparent',
              borderTop: '2px solid currentColor',
              borderRadius: '50%',
              animation: 'spin 1s linear infinite',
            }}
          />
        )}
        {icon && <Box style={{ fontSize: '14px' }}>{icon}</Box>}
        {children && (
          <Box style={{ opacity: loading ? 0.5 : 1 }}>{children}</Box>
        )}
      </Box>
    );
  };

  // Action button with confirmation and feedback
  const ActionButton = ({
    action,
    icon,
    children,
    color = 'default',
    confirmMessage = null,
    successMessage = null,
    errorMessage = null,
    ...props
  }) => {
    const [isLoading, setIsLoading] = React.useState(false);

    const handleAction = async () => {
      if (confirmMessage && !window.confirm(confirmMessage)) {
        return;
      }

      setIsLoading(true);
      try {
        act(action);
        if (successMessage) {
          addNotification('Success', successMessage, 'success');
        }
      } catch (error) {
        if (errorMessage) {
          addNotification('Error', errorMessage, 'error');
        }
      } finally {
        setTimeout(() => setIsLoading(false), 1000);
      }
    };

    return (
      <EnhancedButton
        icon={icon}
        onClick={handleAction}
        color={color}
        loading={isLoading}
        {...props}
      >
        {children}
      </EnhancedButton>
    );
  };

  // Navigation button with active state
  const NavButton = ({
    isActive,
    onClick,
    icon,
    children,
    color = 'default',
  }) => {
    const buttonColor = isActive ? 'blue' : color;

    return (
      <EnhancedButton
        icon={icon}
        onClick={onClick}
        color={buttonColor}
        style={{
          fontWeight: isActive ? 'bold' : 'normal',
          boxShadow: isActive ? '0 0 10px rgba(0,150,255,0.5)' : 'none',
        }}
      >
        {children}
      </EnhancedButton>
    );
  };

  // Grid background pattern
  const GridBackground = () => (
    <Box
      style={{
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        backgroundImage: `
          linear-gradient(rgba(255,255,255,0.03) 1px, transparent 1px),
          linear-gradient(90deg, rgba(255,255,255,0.03) 1px, transparent 1px)
        `,
        backgroundSize: '20px 20px',
        pointerEvents: 'none',
        zIndex: 0,
      }}
    />
  );

  // SCP Foundation watermark logo
  const WatermarkLogo = () => (
    <Box
      style={{
        position: 'absolute',
        bottom: '20%',
        left: '50%',
        transform: 'translateX(-50%)',
        width: '200px',
        height: '200px',
        background:
          'radial-gradient(circle, rgba(255,255,255,0.05) 0%, transparent 70%)',
        borderRadius: '50%',
        filter: 'blur(3px)',
        pointerEvents: 'none',
        zIndex: 0,
      }}
    />
  );

  // Notification components
  const NotificationBell = () => (
    <Box
      style={{
        position: 'relative',
        cursor: 'pointer',
        padding: '8px',
        borderRadius: '4px',
        background:
          notificationCount > 0 ? 'rgba(255,0,0,0.2)' : 'rgba(255,255,255,0.1)',
        border:
          notificationCount > 0
            ? '1px solid rgba(255,0,0,0.5)'
            : '1px solid rgba(255,255,255,0.2)',
        transition: 'all 0.3s ease',
      }}
      onClick={() => setNotificationsOpen(!notificationsOpen)}
    >
      <Box style={{ fontSize: '16px' }}>🔔</Box>
      {notificationCount > 0 && (
        <Box
          style={{
            position: 'absolute',
            top: '-5px',
            right: '-5px',
            background: '#ff0000',
            color: '#ffffff',
            fontSize: '10px',
            padding: '2px 6px',
            borderRadius: '10px',
            minWidth: '16px',
            textAlign: 'center',
            fontWeight: 'bold',
          }}
        >
          {notificationCount > 99 ? '99+' : notificationCount}
        </Box>
      )}
    </Box>
  );

  const NotificationPanel = () => (
    <Box
      style={{
        position: 'absolute',
        top: '60px',
        right: '20px',
        width: '400px',
        maxHeight: '500px',
        background: 'rgba(0,0,0,0.95)',
        border: '1px solid rgba(255,255,255,0.3)',
        borderRadius: '8px',
        padding: '15px',
        zIndex: 1000,
        overflowY: 'auto',
        boxShadow: '0 8px 32px rgba(0,0,0,0.5)',
      }}
    >
      <Box
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          marginBottom: '15px',
          paddingBottom: '10px',
          borderBottom: '1px solid rgba(255,255,255,0.2)',
        }}
      >
        <Box style={{ fontSize: '16px', fontWeight: 'bold' }}>
          Notifications ({notificationCount})
        </Box>
        <Button
          onClick={() => setNotificationHistory([])}
          icon="trash"
          color="bad"
          compact
        >
          Clear All
        </Button>
      </Box>

      {notificationHistory.length === 0 ? (
        <Box style={{ textAlign: 'center', opacity: 0.6, padding: '20px' }}>
          No notifications
        </Box>
      ) : (
        notificationHistory.map((notification, index) => (
          <Box
            key={index}
            style={{
              padding: '10px',
              marginBottom: '8px',
              background:
                notification.type === 'error'
                  ? 'rgba(255,0,0,0.1)'
                  : notification.type === 'warning'
                    ? 'rgba(255,165,0,0.1)'
                    : notification.type === 'success'
                      ? 'rgba(0,255,0,0.1)'
                      : 'rgba(255,255,255,0.05)',
              border: `1px solid ${
                notification.type === 'error'
                  ? 'rgba(255,0,0,0.3)'
                  : notification.type === 'warning'
                    ? 'rgba(255,165,0,0.3)'
                    : notification.type === 'success'
                      ? 'rgba(0,255,0,0.3)'
                      : 'rgba(255,255,255,0.2)'
              }`,
              borderRadius: '4px',
            }}
          >
            <Box
              style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'flex-start',
              }}
            >
              <Box style={{ flex: 1 }}>
                <Box style={{ fontWeight: 'bold', marginBottom: '4px' }}>
                  {notification.title}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                  {notification.message}
                </Box>
                <Box
                  style={{ fontSize: '10px', opacity: 0.6, marginTop: '4px' }}
                >
                  {notification.timestamp}
                </Box>
              </Box>
              <Button
                onClick={() => {
                  const newHistory = notificationHistory.filter(
                    (_, i) => i !== index,
                  );
                  setNotificationHistory(newHistory);
                  setNotificationCount(newHistory.length);
                }}
                icon="times"
                color="transparent"
                compact
              />
            </Box>
          </Box>
        ))
      )}
    </Box>
  );

  const addNotification = (title, message, type = 'info') => {
    const newNotification = {
      title,
      message,
      type,
      timestamp: new Date().toLocaleTimeString(),
    };

    const newHistory = [newNotification, ...notificationHistory].slice(
      0,
      notificationSettings.maxNotifications,
    );
    setNotificationHistory(newHistory);
    setNotificationCount(newHistory.length);

    // Auto-hide after 5 seconds if enabled
    if (notificationSettings.autoHide) {
      setTimeout(() => {
        setNotificationHistory((prev) =>
          prev.filter((n) => n !== newNotification),
        );
        setNotificationCount((prev) => Math.max(0, prev - 1));
      }, 5000);
    }
  };

  // Search components
  const SearchBar = () => (
    <Box
      style={{
        position: 'relative',
        cursor: 'pointer',
        padding: '8px',
        borderRadius: '4px',
        background: 'rgba(255,255,255,0.1)',
        border: '1px solid rgba(255,255,255,0.2)',
        transition: 'all 0.3s ease',
        display: 'flex',
        alignItems: 'center',
        gap: '8px',
      }}
      onClick={() => setSearchOpen(!searchOpen)}
    >
      <Box style={{ fontSize: '14px' }}>🔍</Box>
      <Box style={{ fontSize: '12px', opacity: 0.7 }}>Search...</Box>
    </Box>
  );

  const SearchPanel = () => {
    const performSearch = () => {
      if (!searchTerm.trim()) {
        setSearchResults([]);
        return;
      }

      const results = [];
      const term = searchTerm.toLowerCase();

      // Search through all data sources
      if (searchCategory === 'all' || searchCategory === 'facility') {
        if (facility_data) {
          // Add facility search logic here
          results.push({
            type: 'facility',
            title: 'Facility System',
            description: 'Facility management data',
          });
        }
      }

      if (searchCategory === 'all' || searchCategory === 'scp') {
        if (scp_data) {
          // Add SCP search logic here
          results.push({
            type: 'scp',
            title: 'SCP Containment',
            description: 'SCP containment protocols',
          });
        }
      }

      if (searchCategory === 'all' || searchCategory === 'medical') {
        if (medical_data) {
          // Add medical search logic here
          results.push({
            type: 'medical',
            title: 'Medical Records',
            description: 'Patient and treatment data',
          });
        }
      }

      if (searchCategory === 'all' || searchCategory === 'security') {
        if (security_data) {
          // Add security search logic here
          results.push({
            type: 'security',
            title: 'Security Incidents',
            description: 'Security and incident reports',
          });
        }
      }

      setSearchResults(results);
    };

    React.useEffect(() => {
      performSearch();
    }, [searchTerm, searchCategory]);

    return (
      <Box
        style={{
          position: 'absolute',
          top: '60px',
          left: '50%',
          transform: 'translateX(-50%)',
          width: '600px',
          maxHeight: '500px',
          background: 'rgba(0,0,0,0.95)',
          border: '1px solid rgba(255,255,255,0.3)',
          borderRadius: '8px',
          padding: '15px',
          zIndex: 1000,
          overflowY: 'auto',
          boxShadow: '0 8px 32px rgba(0,0,0,0.5)',
        }}
      >
        <Box
          style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            marginBottom: '15px',
            paddingBottom: '10px',
            borderBottom: '1px solid rgba(255,255,255,0.2)',
          }}
        >
          <Box style={{ fontSize: '16px', fontWeight: 'bold' }}>
            Global Search
          </Box>
          <Button
            onClick={() => setSearchOpen(false)}
            icon="times"
            color="transparent"
            compact
          />
        </Box>

        {/* Search Input */}
        <Box style={{ marginBottom: '15px' }}>
          <Box
            style={{
              display: 'flex',
              gap: '10px',
              marginBottom: '10px',
            }}
          >
            <Box
              style={{
                flex: 1,
                position: 'relative',
              }}
            >
              <Box
                style={{
                  fontSize: '14px',
                  position: 'absolute',
                  left: '10px',
                  top: '50%',
                  transform: 'translateY(-50%)',
                  opacity: 0.6,
                }}
              >
                🔍
              </Box>
              <input
                type="text"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder="Search across all systems..."
                style={{
                  width: '100%',
                  padding: '8px 8px 8px 35px',
                  background: 'rgba(255,255,255,0.1)',
                  border: '1px solid rgba(255,255,255,0.3)',
                  borderRadius: '4px',
                  color: '#ffffff',
                  fontSize: '14px',
                }}
              />
            </Box>
            <select
              value={searchCategory}
              onChange={(e) => setSearchCategory(e.target.value)}
              style={{
                padding: '8px',
                background: 'rgba(255,255,255,0.1)',
                border: '1px solid rgba(255,255,255,0.3)',
                borderRadius: '4px',
                color: '#ffffff',
                fontSize: '14px',
              }}
            >
              <option value="all">All Systems</option>
              <option value="facility">Facility</option>
              <option value="scp">SCP</option>
              <option value="medical">Medical</option>
              <option value="security">Security</option>
              <option value="technology">Technology</option>
              <option value="research">Research</option>
              <option value="personnel">Personnel</option>
              <option value="player">Player Data</option>
            </select>
          </Box>
        </Box>

        {/* Search Results */}
        <Box>
          {searchResults.length === 0 ? (
            <Box style={{ textAlign: 'center', opacity: 0.6, padding: '20px' }}>
              {searchTerm ? 'No results found' : 'Enter a search term to begin'}
            </Box>
          ) : (
            searchResults.map((result, index) => (
              <Box
                key={index}
                style={{
                  padding: '10px',
                  marginBottom: '8px',
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '4px',
                  cursor: 'pointer',
                  transition: 'all 0.2s ease',
                }}
                onClick={() => {
                  setActiveTab(result.type);
                  setSearchOpen(false);
                  addNotification(
                    'Search Result',
                    `Navigated to ${result.title}`,
                    'info',
                  );
                }}
              >
                <Box style={{ fontWeight: 'bold', marginBottom: '4px' }}>
                  {result.title}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                  {result.description}
                </Box>
              </Box>
            ))
          )}
        </Box>
      </Box>
    );
  };

  // Theme components
  const ThemeToggle = () => (
    <Box
      style={{
        position: 'relative',
        cursor: 'pointer',
        padding: '8px',
        borderRadius: '4px',
        background: 'rgba(255,255,255,0.1)',
        border: '1px solid rgba(255,255,255,0.2)',
        transition: 'all 0.3s ease',
        display: 'flex',
        alignItems: 'center',
        gap: '8px',
      }}
      onClick={() => setThemeOpen(!themeOpen)}
    >
      <Box style={{ fontSize: '14px' }}>
        {currentTheme === 'dark' ? '🌙' : '☀️'}
      </Box>
      <Box style={{ fontSize: '12px', opacity: 0.7 }}>Theme</Box>
    </Box>
  );

  const ThemePanel = () => {
    const themes = [
      {
        id: 'dark',
        name: 'Dark Theme',
        icon: '🌙',
        description: 'Classic dark interface',
      },
      {
        id: 'light',
        name: 'Light Theme',
        icon: '☀️',
        description: 'Clean light interface',
      },
      {
        id: 'blue',
        name: 'Blue Theme',
        icon: '🔵',
        description: 'Professional blue interface',
      },
      {
        id: 'green',
        name: 'Green Theme',
        icon: '🟢',
        description: 'Medical green interface',
      },
      {
        id: 'red',
        name: 'Red Theme',
        icon: '🔴',
        description: 'Security red interface',
      },
    ];

    return (
      <Box
        style={{
          position: 'absolute',
          top: '60px',
          right: '20px',
          width: '300px',
          background: 'rgba(0,0,0,0.95)',
          border: '1px solid rgba(255,255,255,0.3)',
          borderRadius: '8px',
          padding: '15px',
          zIndex: 1000,
          boxShadow: '0 8px 32px rgba(0,0,0,0.5)',
        }}
      >
        <Box
          style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            marginBottom: '15px',
            paddingBottom: '10px',
            borderBottom: '1px solid rgba(255,255,255,0.2)',
          }}
        >
          <Box style={{ fontSize: '16px', fontWeight: 'bold' }}>
            Theme Selection
          </Box>
          <Button
            onClick={() => setThemeOpen(false)}
            icon="times"
            color="transparent"
            compact
          />
        </Box>

        <Box style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
          {themes.map((theme) => (
            <Box
              key={theme.id}
              style={{
                padding: '10px',
                background:
                  currentTheme === theme.id
                    ? 'rgba(255,255,255,0.1)'
                    : 'rgba(255,255,255,0.05)',
                border: `1px solid ${currentTheme === theme.id ? 'rgba(255,255,255,0.3)' : 'rgba(255,255,255,0.2)'}`,
                borderRadius: '4px',
                cursor: 'pointer',
                transition: 'all 0.2s ease',
                display: 'flex',
                alignItems: 'center',
                gap: '10px',
              }}
              onClick={() => {
                setCurrentTheme(theme.id);
                setThemeOpen(false);
                addNotification(
                  'Theme Changed',
                  `Switched to ${theme.name}`,
                  'info',
                );
              }}
            >
              <Box style={{ fontSize: '16px' }}>{theme.icon}</Box>
              <Box style={{ flex: 1 }}>
                <Box style={{ fontWeight: 'bold', fontSize: '14px' }}>
                  {theme.name}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  {theme.description}
                </Box>
              </Box>
              {currentTheme === theme.id && (
                <Box style={{ fontSize: '12px', color: '#00ff00' }}>✓</Box>
              )}
            </Box>
          ))}
        </Box>
      </Box>
    );
  };

  // Desktop-style interface with icons
  const DesktopInterface = () => (
    <Box
      style={{
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        background:
          'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)',
        padding: '20px',
        zIndex: 10,
        fontFamily: 'monospace',
        color: '#ffffff',
        overflow: 'hidden',
      }}
    >
      {/* Desktop Header */}
      <Box
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          height: '50px',
          background: 'rgba(0,0,0,0.9)',
          borderBottom: '2px solid rgba(255,255,255,0.3)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          padding: '0 20px',
          zIndex: 15,
        }}
      >
        <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
          SCP FOUNDATION - PERSISTENCE CONTROL SYSTEM
        </Box>
        <Box style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
          <SearchBar />
          <NotificationBell />
          <ThemeToggle />
          <Box style={{ fontSize: '14px', opacity: 0.8 }}>
            {new Date().toLocaleString()}
          </Box>
        </Box>
      </Box>

      {/* Main Content Area */}
      <Box
        style={{
          position: 'absolute',
          top: '70px',
          left: '20px',
          right: '400px',
          bottom: '20px',
          display: 'flex',
          flexDirection: 'column',
          gap: '20px',
          overflow: 'hidden',
        }}
      >
        {/* Top Row of Icons */}
        <Box
          style={{
            display: 'flex',
            gap: '20px',
            justifyContent: 'flex-start',
          }}
        >
          <DesktopIcon
            icon="🖥️"
            label="TERMINAL"
            onClick={() => setActiveTab('terminal')}
            isActive={activeTab === 'terminal'}
          />
          <DesktopIcon
            icon="🏢"
            label="FACILITY"
            onClick={() => setActiveTab('facility')}
            isActive={activeTab === 'facility'}
          />
          <DesktopIcon
            icon="🔒"
            label="SCP CONTAINMENT"
            onClick={() => setActiveTab('scp')}
            isActive={activeTab === 'scp'}
          />
          <DesktopIcon
            icon="⚡"
            label="TECHNOLOGY"
            onClick={() => setActiveTab('technology')}
            isActive={activeTab === 'technology'}
          />
          <DesktopIcon
            icon="🏥"
            label="MEDICAL"
            onClick={() => setActiveTab('medical')}
            isActive={activeTab === 'medical'}
          />
          <DesktopIcon
            icon="🛡️"
            label="SECURITY"
            onClick={() => setActiveTab('security')}
            isActive={activeTab === 'security'}
          />
          <DesktopIcon
            icon="🔬"
            label="RESEARCH"
            onClick={() => setActiveTab('research')}
            isActive={activeTab === 'research'}
          />
          <DesktopIcon
            icon="👥"
            label="PERSONNEL"
            onClick={() => setActiveTab('personnel')}
            isActive={activeTab === 'personnel'}
          />
        </Box>

        {/* Bottom Row of Icons */}
        <Box
          style={{
            display: 'flex',
            gap: '20px',
            justifyContent: 'flex-start',
          }}
        >
          <DesktopIcon
            icon="🎮"
            label="PLAYER DATA"
            onClick={() => setActiveTab('players')}
            isActive={activeTab === 'players'}
          />

          <DesktopIcon
            icon="🏗️"
            label="INFRASTRUCTURE"
            onClick={() => setActiveTab('infrastructure')}
            isActive={activeTab === 'infrastructure'}
          />
          <DesktopIcon
            icon="📊"
            label="ANALYTICS"
            onClick={() => setActiveTab('analytics')}
            isActive={activeTab === 'analytics'}
          />
          <DesktopIcon
            icon="💰"
            label="BUDGET"
            onClick={() => setActiveTab('budget')}
            isActive={activeTab === 'budget'}
          />
        </Box>
      </Box>

      {/* SCIPNET Panel */}
      <Box
        style={{
          position: 'absolute',
          top: '70px',
          right: '20px',
          width: scipnetCollapsed ? '60px' : '360px',
          bottom: '20px',
          background: 'rgba(0,0,0,0.8)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: '5px',
          padding: scipnetCollapsed ? '10px' : '20px',
          fontFamily: 'monospace',
          fontSize: '12px',
          color: '#ffffff',
          overflowY: 'auto',
          transition: 'all 0.3s ease',
        }}
      >
        <Box
          style={{
            fontSize: scipnetCollapsed ? '12px' : '16px',
            fontWeight: 'bold',
            marginBottom: scipnetCollapsed ? '0' : '15px',
            textAlign: 'center',
            borderBottom: scipnetCollapsed
              ? 'none'
              : '1px solid rgba(255,255,255,0.2)',
            paddingBottom: scipnetCollapsed ? '0' : '10px',
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '8px',
          }}
          onClick={() => setScipnetCollapsed(!scipnetCollapsed)}
        >
          {scipnetCollapsed ? (
            <>
              <Box style={{ transform: 'rotate(90deg)', fontSize: '14px' }}>
                ▶
              </Box>
              <Box style={{ transform: 'rotate(90deg)', fontSize: '10px' }}>
                SCIPNET
              </Box>
            </>
          ) : (
            <>
              <Box>SCIPNET</Box>
              <Box
                style={{
                  fontSize: '12px',
                  cursor: 'pointer',
                  padding: '2px 6px',
                  background: 'rgba(255,255,255,0.1)',
                  borderRadius: '3px',
                  marginLeft: 'auto',
                }}
                onClick={(e) => {
                  e.stopPropagation();
                  setScipnetCollapsed(true);
                }}
              >
                −
              </Box>
            </>
          )}
        </Box>

        {/* Redacted Information */}
        {!scipnetCollapsed && (
          <>
            <Box style={{ marginBottom: '15px' }}>
              <Box
                style={{
                  marginBottom: '3px',
                  color: '#ff6666',
                  fontSize: '11px',
                }}
              >
                COUNTRY: [REDACTED]
              </Box>
              <Box
                style={{
                  marginBottom: '3px',
                  color: '#ff6666',
                  fontSize: '11px',
                }}
              >
                REGION: [REDACTED]
              </Box>
              <Box
                style={{
                  marginBottom: '10px',
                  color: '#ff6666',
                  fontSize: '11px',
                }}
              >
                IP ADDRESS: [REDACTED]
              </Box>

              {/* Incidents Section */}
              <Box
                style={{
                  marginBottom: '15px',
                  padding: '8px',
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.1)',
                  borderRadius: '3px',
                }}
              >
                <Box
                  style={{
                    fontSize: '13px',
                    fontWeight: 'bold',
                    marginBottom: '3px',
                  }}
                >
                  INCIDENTS
                </Box>
                <Box style={{ fontSize: '11px', opacity: 0.8 }}>
                  0 Total Reported
                </Box>
              </Box>

              <Box
                style={{
                  display: 'flex',
                  gap: '8px',
                  marginBottom: '15px',
                }}
              >
                <Box
                  style={{
                    padding: '6px 10px',
                    background: 'rgba(255,255,255,0.1)',
                    border: '1px solid rgba(255,255,255,0.2)',
                    borderRadius: '3px',
                    opacity: 0.5,
                    fontSize: '9px',
                  }}
                >
                  RESEARCH
                </Box>
                <Box
                  style={{
                    padding: '6px 10px',
                    background: 'rgba(255,255,255,0.1)',
                    border: '1px solid rgba(255,255,255,0.2)',
                    borderRadius: '3px',
                    opacity: 0.5,
                    fontSize: '9px',
                  }}
                >
                  PERSONNEL
                </Box>
              </Box>
            </Box>

            {/* System Overview */}
            <Box style={{ marginBottom: '15px' }}>
              <Box
                style={{
                  fontSize: '13px',
                  fontWeight: 'bold',
                  marginBottom: '8px',
                }}
              >
                SYSTEM OVERVIEW:
              </Box>
              <Box style={{ marginBottom: '5px' }}>
                <span style={{ color: '#00ff00' }}>●</span> FACILITY: LIVE
              </Box>
              <Box style={{ marginBottom: '5px' }}>
                <span style={{ color: '#00ff00' }}>●</span> SCP: LIVE
              </Box>
              <Box style={{ marginBottom: '5px' }}>
                <span style={{ color: '#00ff00' }}>●</span> TECHNOLOGY: LIVE
              </Box>
              <Box style={{ marginBottom: '5px' }}>
                <span style={{ color: '#00ff00' }}>●</span> MEDICAL: LIVE
              </Box>
              <Box style={{ marginBottom: '5px' }}>
                <span style={{ color: '#00ff00' }}>●</span> SECURITY: LIVE
              </Box>
              <Box style={{ marginBottom: '5px' }}>
                <span style={{ color: '#00ff00' }}>●</span> RESEARCH: LIVE
              </Box>
              <Box style={{ marginBottom: '5px' }}>
                <span style={{ color: '#00ff00' }}>●</span> PERSONNEL: LIVE
              </Box>
              <Box style={{ marginBottom: '5px' }}>
                <span style={{ color: '#00ff00' }}>●</span> PLAYER: LIVE
              </Box>
            </Box>

            {/* Key Metrics */}
            <Box style={{ marginBottom: '20px' }}>
              <Box
                style={{
                  fontSize: '14px',
                  fontWeight: 'bold',
                  marginBottom: '10px',
                }}
              >
                KEY METRICS:
              </Box>
              <Box style={{ marginBottom: '5px' }}>ACTIVE THREATS: 0</Box>
              <Box style={{ marginBottom: '5px' }}>OUTBREAKS: 0</Box>
              <Box style={{ marginBottom: '5px' }}>BREACHES: 0</Box>
              <Box style={{ marginBottom: '5px' }}>STAFF: 0</Box>
              <Box style={{ marginBottom: '5px' }}>PROJECTS: 0</Box>
              <Box style={{ marginBottom: '5px' }}>PLAYERS: 0</Box>
            </Box>

            {/* Live Alerts */}
            <Box>
              <Box
                style={{
                  fontSize: '14px',
                  fontWeight: 'bold',
                  marginBottom: '10px',
                }}
              >
                LIVE ALERTS:
              </Box>
              <Box
                style={{
                  padding: '8px 12px',
                  background: 'rgba(0,255,0,0.2)',
                  border: '1px solid rgba(0,255,0,0.5)',
                  borderRadius: '3px',
                  fontSize: '10px',
                }}
              >
                INFO: All systems operational
              </Box>
              <Box style={{ fontSize: '10px', opacity: 0.7, marginTop: '5px' }}>
                No recent alerts
              </Box>
            </Box>
          </>
        )}
      </Box>

      {/* Notification Panel */}
      {notificationsOpen && <NotificationPanel />}

      {/* Search Panel */}
      {searchOpen && <SearchPanel />}

      {/* Theme Panel */}
      {themeOpen && <ThemePanel />}

      {/* Debug Modal State */}
      <Box
        style={{
          position: 'fixed',
          top: '10px',
          left: '10px',
          background: 'red',
          color: 'white',
          padding: '5px',
          zIndex: 9999,
          fontSize: '12px',
        }}
      >
        Modal State: {researchModalOpen ? 'OPEN' : 'CLOSED'}
      </Box>
    </Box>
  );

  // Desktop Icon Component
  const DesktopIcon = ({ icon, label, onClick, isActive }) => (
    <Box
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        width: '120px',
        height: '120px',
        background: isActive
          ? 'rgba(255,255,255,0.2)'
          : 'rgba(255,255,255,0.05)',
        border: isActive
          ? '2px solid rgba(255,255,255,0.8)'
          : '2px solid rgba(255,255,255,0.2)',
        borderRadius: '10px',
        cursor: 'pointer',
        transition: 'all 0.3s ease',
        padding: '10px',
        textAlign: 'center',
        backdropFilter: 'blur(10px)',
        boxShadow: isActive
          ? '0 8px 32px rgba(255,255,255,0.3)'
          : '0 4px 16px rgba(0,0,0,0.3)',
      }}
      onClick={onClick}
      onMouseEnter={(e) => {
        e.target.style.transform = 'scale(1.05)';
        e.target.style.background = 'rgba(255,255,255,0.15)';
      }}
      onMouseLeave={(e) => {
        e.target.style.transform = 'scale(1)';
        e.target.style.background = isActive
          ? 'rgba(255,255,255,0.2)'
          : 'rgba(255,255,255,0.05)';
      }}
    >
      <Box
        style={{
          fontSize: '32px',
          marginBottom: '8px',
          filter: isActive
            ? 'drop-shadow(0 0 8px rgba(255,255,255,0.5))'
            : 'none',
        }}
      >
        {icon}
      </Box>
      <Box
        style={{
          fontSize: '10px',
          fontWeight: 'bold',
          textAlign: 'center',
          lineHeight: '1.2',
          opacity: isActive ? 1 : 0.8,
        }}
      >
        {label}
      </Box>
    </Box>
  );

  // Terminal interface
  const TerminalInterface = () => (
    <Box
      style={{
        background: 'rgba(0,0,0,0.7)',
        border: '1px solid rgba(255,255,255,0.2)',
        borderRadius: '5px',
        padding: '20px',
        fontFamily: 'monospace',
        fontSize: '14px',
        color: '#ffffff',
        minHeight: '100%',
        position: 'relative',
      }}
    >
      {/* Back to Desktop Button */}
      <Box
        style={{
          position: 'absolute',
          top: '10px',
          right: '10px',
          padding: '8px 16px',
          background: 'rgba(255,255,255,0.1)',
          border: '1px solid rgba(255,255,255,0.3)',
          borderRadius: '5px',
          cursor: 'pointer',
          fontSize: '12px',
          transition: 'all 0.3s ease',
        }}
        onClick={() => setActiveTab('desktop')}
        onMouseEnter={(e) => {
          e.target.style.background = 'rgba(255,255,255,0.2)';
        }}
        onMouseLeave={(e) => {
          e.target.style.background = 'rgba(255,255,255,0.1)';
        }}
      >
        ← BACK TO DESKTOP
      </Box>
      <Box style={{ marginBottom: '20px' }}>
        <Box
          style={{
            fontSize: '24px',
            fontWeight: 'bold',
            marginBottom: '5px',
          }}
        >
          TERMINAL PERSISTENCE
        </Box>
        <Box style={{ fontSize: '16px', opacity: 0.8 }}>
          SYSTEM ACCESS & CONTROL
        </Box>
      </Box>

      <Box style={{ marginBottom: '20px' }}>
        <Box style={{ marginBottom: '15px' }}>
          {Array(50).fill('─').join('')}
        </Box>
        <Box style={{ textAlign: 'center', marginBottom: '15px' }}>
          TERMINAL PERSISTENCE SYSTEM
        </Box>
        <Box style={{ marginBottom: '15px' }}>
          {Array(50).fill('─').join('')}
        </Box>
      </Box>

      {/* Terminal Controls */}
      <Box style={{ marginBottom: '20px' }}>
        <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
          TERMINAL CONTROLS:
        </Box>
        <Flex wrap="wrap" style={{ gap: '10px', marginBottom: '20px' }}>
          <ActionButton
            action="terminal_access"
            icon="🔓"
            color="blue"
            successMessage="System access granted"
            errorMessage="Access denied"
            tooltip="Access the main system"
          >
            ACCESS SYSTEM
          </ActionButton>
          <ActionButton
            action="terminal_help"
            icon="❓"
            color="default"
            successMessage="Help documentation loaded"
            tooltip="View system help"
          >
            HELP
          </ActionButton>
          <ActionButton
            action="terminal_status"
            icon="📊"
            color="good"
            successMessage="System status retrieved"
            tooltip="Check system status"
          >
            SYSTEM STATUS
          </ActionButton>
          <EnhancedButton
            icon="🔄"
            color="purple"
            onClick={() => {
              addNotification(
                'System Refresh',
                'Refreshing terminal data...',
                'info',
              );
              setTimeout(
                () =>
                  addNotification(
                    'System Refresh',
                    'Terminal data refreshed successfully',
                    'success',
                  ),
                1000,
              );
            }}
            tooltip="Refresh terminal data"
          >
            REFRESH
          </EnhancedButton>
          <EnhancedButton
            icon="⚙️"
            color="average"
            onClick={() => {
              addNotification(
                'Settings',
                'Opening terminal settings...',
                'info',
              );
            }}
            tooltip="Terminal settings"
          >
            SETTINGS
          </EnhancedButton>
        </Flex>
      </Box>

      {/* Terminal Status */}
      <Box style={{ marginBottom: '20px' }}>
        <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
          TERMINAL STATUS:
        </Box>
        <Grid style={{ gap: '10px' }}>
          <Grid.Column size={3}>
            <Box
              style={{
                background: 'rgba(255,255,255,0.05)',
                border: '1px solid rgba(255,255,255,0.2)',
                borderRadius: '3px',
                padding: '15px',
                textAlign: 'center',
              }}
            >
              <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>ONLINE</Box>
              <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                SYSTEM STATUS
              </Box>
            </Box>
          </Grid.Column>
          <Grid.Column size={3}>
            <Box
              style={{
                background: 'rgba(255,255,255,0.05)',
                border: '1px solid rgba(255,255,255,0.2)',
                borderRadius: '3px',
                padding: '15px',
                textAlign: 'center',
              }}
            >
              <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                {new Date().toLocaleTimeString()}
              </Box>
              <Box style={{ fontSize: '12px', opacity: 0.7 }}>CURRENT TIME</Box>
            </Box>
          </Grid.Column>
          <Grid.Column size={3}>
            <Box
              style={{
                background: 'rgba(255,255,255,0.05)',
                border: '1px solid rgba(255,255,255,0.2)',
                borderRadius: '3px',
                padding: '15px',
                textAlign: 'center',
              }}
            >
              <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>v4.1.3</Box>
              <Box style={{ fontSize: '12px', opacity: 0.7 }}>VERSION</Box>
            </Box>
          </Grid.Column>
          <Grid.Column size={3}>
            <Box
              style={{
                background: 'rgba(255,255,255,0.05)',
                border: '1px solid rgba(255,255,255,0.2)',
                borderRadius: '3px',
                padding: '15px',
                textAlign: 'center',
              }}
            >
              <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>SECURE</Box>
              <Box style={{ fontSize: '12px', opacity: 0.7 }}>CONNECTION</Box>
            </Box>
          </Grid.Column>
        </Grid>
      </Box>

      <Box style={{ fontSize: '12px', opacity: 0.7, textAlign: 'center' }}>
        Terminal persistence system providing secure access to SCP Foundation
        databases and control systems.
      </Box>
    </Box>
  );

  // Facility Management Interface
  const FacilityInterface = ({ facilityActiveTab, setFacilityActiveTab }) => {
    const [selectedRoom, setSelectedRoom] = React.useState(null);
    const [selectedEquipment, setSelectedEquipment] = React.useState(null);
    const [selectedSystem, setSelectedSystem] = React.useState(null);
    const [searchTerm, setSearchTerm] = React.useState('');
    const [filterType, setFilterType] = React.useState('all');

    return (
      <Box
        style={{
          background: 'rgba(0,0,0,0.7)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: '5px',
          padding: '20px',
          fontFamily: 'monospace',
          fontSize: '14px',
          color: '#ffffff',
          minHeight: '100%',
          position: 'relative',
        }}
      >
        {/* Back to Desktop Button */}
        <Box
          style={{
            position: 'absolute',
            top: '10px',
            right: '10px',
            padding: '8px 16px',
            background: 'rgba(255,255,255,0.1)',
            border: '1px solid rgba(255,255,255,0.3)',
            borderRadius: '5px',
            cursor: 'pointer',
            fontSize: '12px',
            transition: 'all 0.3s ease',
          }}
          onClick={() => setActiveTab('desktop')}
          onMouseEnter={(e) => {
            e.target.style.background = 'rgba(255,255,255,0.2)';
          }}
          onMouseLeave={(e) => {
            e.target.style.background = 'rgba(255,255,255,0.1)';
          }}
        >
          ← BACK TO DESKTOP
        </Box>
        <Box style={{ marginBottom: '20px' }}>
          <Box
            style={{
              fontSize: '24px',
              fontWeight: 'bold',
              marginBottom: '5px',
            }}
          >
            FACILITY PERSISTENCE
          </Box>
          <Box style={{ fontSize: '16px', opacity: 0.8 }}>
            ENGINEERING & MAINTENANCE
          </Box>
        </Box>

        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
          <Box style={{ textAlign: 'center', marginBottom: '15px' }}>
            FACILITY PERSISTENCE SYSTEM
          </Box>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
        </Box>

        {/* Facility Controls */}
        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            FACILITY CONTROLS:
          </Box>
          <Flex wrap="wrap" style={{ gap: '10px', marginBottom: '20px' }}>
            <ActionButton
              action="facility_view_status"
              icon="📊"
              color="blue"
              successMessage="Facility status retrieved"
              tooltip="View facility status"
            >
              VIEW STATUS
            </ActionButton>
            <ActionButton
              action="facility_save_data"
              icon="💾"
              color="good"
              successMessage="Facility data saved successfully"
              errorMessage="Failed to save facility data"
              tooltip="Save facility data"
            >
              SAVE DATA
            </ActionButton>
            <ActionButton
              action="facility_load_data"
              icon="📂"
              color="default"
              successMessage="Facility data loaded successfully"
              errorMessage="Failed to load facility data"
              tooltip="Load facility data"
            >
              LOAD DATA
            </ActionButton>
            <ActionButton
              action="facility_reset_data"
              icon="🔄"
              color="bad"
              confirmMessage="Are you sure you want to reset all facility data? This action cannot be undone."
              successMessage="Facility data reset successfully"
              errorMessage="Failed to reset facility data"
              tooltip="Reset all facility data (DANGEROUS)"
            >
              RESET DATA
            </ActionButton>
            <ActionButton
              action="test_systems"
              icon="🧪"
              color="purple"
              successMessage="System tests completed"
              tooltip="Run system diagnostics"
            >
              TEST SYSTEMS
            </ActionButton>
            <EnhancedButton
              icon="🏢"
              color="good"
              onClick={() => setFacilityModalOpen(true)}
              tooltip="Open detailed facility registration form"
            >
              ADD FACILITY
            </EnhancedButton>
            <EnhancedButton
              icon="🔧"
              color="average"
              onClick={() => {
                addNotification(
                  'Maintenance',
                  'Scheduling facility maintenance...',
                  'info',
                );
                setTimeout(
                  () =>
                    addNotification(
                      'Maintenance',
                      'Maintenance scheduled successfully',
                      'success',
                    ),
                  1500,
                );
              }}
              tooltip="Schedule maintenance"
            >
              MAINTENANCE
            </EnhancedButton>
            <EnhancedButton
              icon="⚡"
              color="blue"
              onClick={() => {
                addNotification(
                  'Power Systems',
                  'Checking power grid status...',
                  'info',
                );
                setTimeout(
                  () =>
                    addNotification(
                      'Power Systems',
                      'Power grid operational',
                      'success',
                    ),
                  1200,
                );
              }}
              tooltip="Power grid status"
            >
              POWER GRID
            </EnhancedButton>
          </Flex>
        </Box>

        {/* Facility Status */}
        <Box style={{ lineHeight: '1.6' }}>
          <Box style={{ marginBottom: '10px', fontWeight: 'bold' }}>
            FACILITY STATUS:
            <DataStatusIndicator data={facility_data} label="FACILITY" />
          </Box>
          <Box>ROOM STATES: {facility_data?.room_states_count || 0}/50</Box>
          <Box>EQUIPMENT: {facility_data?.equipment_operational || 0}/45</Box>
          <Box>SECURITY: {facility_data?.security_systems_count || 0}/15</Box>
          <Box>
            POWER EFFICIENCY:{' '}
            {facility_data?.power_efficiency
              ? Math.round(facility_data.power_efficiency * 100)
              : 0}
            %
          </Box>
          <Box>
            CONTAINMENT STABILITY: {facility_data?.containment_stability || 0}%
          </Box>
          <Box>FACILITY HEALTH: {facility_data?.facility_health || 0}%</Box>
          <Box>MAINTENANCE LEVEL: {facility_data?.maintenance_level || 0}%</Box>
          <Box>SECURITY LEVEL: {facility_data?.security_level || 0}</Box>
        </Box>

        {/* Facility Navigation Tabs */}
        <Flex
          style={{
            marginBottom: '20px',
            borderBottom: '1px solid rgba(255,255,255,0.3)',
            gap: '5px',
          }}
        >
          <NavButton
            isActive={facilityActiveTab === 'overview'}
            onClick={() => setFacilityActiveTab('overview')}
            icon="📊"
          >
            OVERVIEW
          </NavButton>
          <NavButton
            isActive={facilityActiveTab === 'rooms'}
            onClick={() => setFacilityActiveTab('rooms')}
            icon="🏠"
          >
            ROOMS
          </NavButton>
          <NavButton
            isActive={facilityActiveTab === 'equipment'}
            onClick={() => setFacilityActiveTab('equipment')}
            icon="⚙️"
          >
            EQUIPMENT
          </NavButton>
          <NavButton
            isActive={facilityActiveTab === 'systems'}
            onClick={() => setFacilityActiveTab('systems')}
            icon="🔧"
          >
            SYSTEMS
          </NavButton>
          <NavButton
            isActive={facilityActiveTab === 'maintenance'}
            onClick={() => setFacilityActiveTab('maintenance')}
            icon="🔨"
          >
            MAINTENANCE
          </NavButton>
        </Flex>

        {/* Overview Tab */}
        {facilityActiveTab === 'overview' && (
          <Box>
            <Box
              style={{
                fontSize: '12px',
                opacity: 0.7,
                textAlign: 'center',
                marginTop: '20px',
              }}
            >
              Facility system overview - all systems operational.
            </Box>
          </Box>
        )}

        {/* Rooms Tab */}
        {facilityActiveTab === 'rooms' && (
          <Box>
            <Section title="Room Management">
              <Table>
                <Table.Row header>
                  <Table.Cell>Room ID</Table.Cell>
                  <Table.Cell>Type</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Security Level</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>ROOM-001</Table.Cell>
                  <Table.Cell>Containment Cell</Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: '#66ff66', fontWeight: 'bold' }}>
                      OPERATIONAL
                    </Box>
                  </Table.Cell>
                  <Table.Cell>Level 5</Table.Cell>
                  <Table.Cell>
                    <Button
                      size="small"
                      onClick={() => setSelectedRoom('ROOM-001')}
                    >
                      View
                    </Button>
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Section>
          </Box>
        )}

        {/* Equipment Tab */}
        {facilityActiveTab === 'equipment' && (
          <Box>
            <Section title="Equipment Management">
              <Table>
                <Table.Row header>
                  <Table.Cell>Equipment ID</Table.Cell>
                  <Table.Cell>Type</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Efficiency</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>EQ-001</Table.Cell>
                  <Table.Cell>Power Generator</Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: '#66ff66', fontWeight: 'bold' }}>
                      OPERATIONAL
                    </Box>
                  </Table.Cell>
                  <Table.Cell>
                    <ProgressBar value={95} maxValue={100} color="good" />
                  </Table.Cell>
                  <Table.Cell>
                    <Button
                      size="small"
                      onClick={() => setSelectedEquipment('EQ-001')}
                    >
                      View
                    </Button>
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Section>
          </Box>
        )}

        {/* Systems Tab */}
        {facilityActiveTab === 'systems' && (
          <Box>
            <Section title="System Management">
              <Table>
                <Table.Row header>
                  <Table.Cell>System</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Priority</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>Containment Field Generator</Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: '#66ff66', fontWeight: 'bold' }}>
                      ONLINE
                    </Box>
                  </Table.Cell>
                  <Table.Cell>CRITICAL</Table.Cell>
                  <Table.Cell>
                    <Button
                      size="small"
                      color="red"
                      onClick={() =>
                        act('facility_shutdown_system', {
                          system: 'containment',
                        })
                      }
                    >
                      Shutdown
                    </Button>
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Section>
          </Box>
        )}

        {/* Maintenance Tab */}
        {facilityActiveTab === 'maintenance' && (
          <Box>
            <Section title="Maintenance Schedule">
              <Table>
                <Table.Row header>
                  <Table.Cell>Task</Table.Cell>
                  <Table.Cell>Priority</Table.Cell>
                  <Table.Cell>Assigned To</Table.Cell>
                  <Table.Cell>Due Date</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>Power Grid Maintenance</Table.Cell>
                  <Table.Cell>HIGH</Table.Cell>
                  <Table.Cell>Engineering Team</Table.Cell>
                  <Table.Cell>2024-01-20</Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: '#ffaa00', fontWeight: 'bold' }}>
                      IN PROGRESS
                    </Box>
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Section>
          </Box>
        )}

        {/* Modals */}
        {selectedRoom && (
          <Modal>
            <Section title={`Room Details: ${selectedRoom}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Room:</strong> {selectedRoom}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> Operational
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Type:</strong> Facility Room
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  Room details will be populated from facility data.
                </Box>
              </Box>
              <Button onClick={() => setSelectedRoom(null)}>Close</Button>
            </Section>
          </Modal>
        )}

        {selectedEquipment && (
          <Modal>
            <Section title={`Equipment Details: ${selectedEquipment}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Equipment:</strong> {selectedEquipment}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> Operational
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Type:</strong> Facility Equipment
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  Equipment details will be populated from facility data.
                </Box>
              </Box>
              <Button onClick={() => setSelectedEquipment(null)}>Close</Button>
            </Section>
          </Modal>
        )}
      </Box>
    );
  };

  // SCP Management Interface
  const SCPInterface = ({ scpActiveTab, setScpActiveTab }) => {
    const [selectedSCP, setSelectedSCP] = useLocalState(
      context,
      'scpSelectedSCP',
      null,
    );
    const [selectedBreach, setSelectedBreach] = useLocalState(
      context,
      'scpSelectedBreach',
      null,
    );
    const [searchTerm, setSearchTerm] = useLocalState(
      context,
      'scpSearchTerm',
      '',
    );
    const [filterType, setFilterType] = useLocalState(
      context,
      'scpFilterType',
      'all',
    );

    return (
      <Box
        style={{
          background: 'rgba(0,0,0,0.7)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: '5px',
          padding: '20px',
          fontFamily: 'monospace',
          fontSize: '14px',
          color: '#ffffff',
          minHeight: '100%',
          position: 'relative',
        }}
      >
        {/* Back to Desktop Button */}
        <Box
          style={{
            position: 'absolute',
            top: '10px',
            right: '10px',
            padding: '8px 16px',
            background: 'rgba(255,255,255,0.1)',
            border: '1px solid rgba(255,255,255,0.3)',
            borderRadius: '5px',
            cursor: 'pointer',
            fontSize: '12px',
            transition: 'all 0.3s ease',
          }}
          onClick={() => setActiveTab('desktop')}
          onMouseEnter={(e) => {
            e.target.style.background = 'rgba(255,255,255,0.2)';
          }}
          onMouseLeave={(e) => {
            e.target.style.background = 'rgba(255,255,255,0.1)';
          }}
        >
          ← BACK TO DESKTOP
        </Box>
        <Box style={{ marginBottom: '20px' }}>
          <Box
            style={{
              fontSize: '24px',
              fontWeight: 'bold',
              marginBottom: '5px',
            }}
          >
            SCP PERSISTENCE
          </Box>
          <Box style={{ fontSize: '16px', opacity: 0.8 }}>
            CONTAINMENT & SECURITY
          </Box>
        </Box>

        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
          <Box style={{ textAlign: 'center', marginBottom: '15px' }}>
            SCP PERSISTENCE SYSTEM
          </Box>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
        </Box>

        {/* SCP Controls */}
        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            SCP CONTROLS:
          </Box>
          <Flex wrap="wrap" style={{ gap: '10px', marginBottom: '20px' }}>
            <ActionButton
              action="scp_view_status"
              icon="📊"
              color="blue"
              successMessage="SCP status retrieved"
              tooltip="View SCP containment status"
            >
              VIEW STATUS
            </ActionButton>
            <EnhancedButton
              icon="🔒"
              color="purple"
              onClick={() => setScpModalOpen(true)}
              tooltip="Open detailed SCP instance creation form"
            >
              ADD SCP
            </EnhancedButton>
            <ActionButton
              action="scp_add_research"
              icon="🔬"
              color="default"
              successMessage="Research project added successfully"
              errorMessage="Failed to add research project"
              tooltip="Add new research project"
            >
              ADD RESEARCH
            </ActionButton>
            <ActionButton
              action="scp_save_data"
              icon="💾"
              color="good"
              successMessage="SCP data saved successfully"
              errorMessage="Failed to save SCP data"
              tooltip="Save SCP data"
            >
              SAVE DATA
            </ActionButton>
            <EnhancedButton
              icon="🚨"
              color="bad"
              onClick={() => {
                addNotification(
                  'Containment Alert',
                  'Checking containment systems...',
                  'warning',
                );
                setTimeout(
                  () =>
                    addNotification(
                      'Containment Alert',
                      'All containment systems operational',
                      'success',
                    ),
                  1500,
                );
              }}
              tooltip="Emergency containment check"
            >
              CONTAINMENT CHECK
            </EnhancedButton>
            <EnhancedButton
              icon="📋"
              color="average"
              onClick={() => {
                addNotification(
                  'Protocol Review',
                  'Loading containment protocols...',
                  'info',
                );
              }}
              tooltip="Review containment protocols"
            >
              PROTOCOLS
            </EnhancedButton>
          </Flex>
        </Box>

        {/* SCP Status */}
        <Box style={{ lineHeight: '1.6' }}>
          <Box style={{ marginBottom: '10px', fontWeight: 'bold' }}>
            CONTAINMENT STATUS:{' '}
            {scp_data?.active_breaches > 0 ? 'BREACH DETECTED' : 'SECURE'}
            <DataStatusIndicator data={scp_data} label="SCP" />
          </Box>
          {scp_data?.active_breaches > 0 && (
            <Box
              style={{
                color: '#ff6666',
                marginBottom: '10px',
                fontWeight: 'bold',
              }}
            >
              WARNING: {scp_data.active_breaches} ACTIVE BREACH(ES) DETECTED
            </Box>
          )}
          <Box>
            GLOBAL STABILITY: {scp_data?.global_containment_stability || 0}%
          </Box>
          <Box>RESEARCH PROGRESS: {scp_data?.research_progress || 0}%</Box>
          <Box>SCP INSTANCES: {scp_data?.scp_instances_count || 0}</Box>
          <Box>
            CONTAINMENT EFFECTIVENESS:{' '}
            {scp_data?.containment_effectiveness
              ? Math.round(scp_data.containment_effectiveness * 100)
              : 0}
            %
          </Box>
        </Box>

        {/* SCP Navigation Tabs */}
        <Flex
          style={{
            marginBottom: '20px',
            borderBottom: '1px solid rgba(255,255,255,0.3)',
            gap: '5px',
          }}
        >
          <NavButton
            isActive={scpActiveTab === 'overview'}
            onClick={() => setScpActiveTab('overview')}
            icon="📊"
          >
            OVERVIEW
          </NavButton>
          <NavButton
            isActive={scpActiveTab === 'instances'}
            onClick={() => setScpActiveTab('instances')}
            icon="🔒"
          >
            INSTANCES
          </NavButton>
          <NavButton
            isActive={scpActiveTab === 'breaches'}
            onClick={() => setScpActiveTab('breaches')}
            icon="🚨"
          >
            BREACHES
          </NavButton>
          <NavButton
            isActive={scpActiveTab === 'research'}
            onClick={() => setScpActiveTab('research')}
            icon="🔬"
          >
            RESEARCH
          </NavButton>
          <NavButton
            isActive={scpActiveTab === 'protocols'}
            onClick={() => setScpActiveTab('protocols')}
            icon="📋"
          >
            PROTOCOLS
          </NavButton>
        </Flex>

        {/* Overview Tab */}
        {scpActiveTab === 'overview' && (
          <Box>
            <Box
              style={{
                fontSize: '12px',
                opacity: 0.7,
                textAlign: 'center',
                marginTop: '20px',
              }}
            >
              SCP containment overview - all systems operational.
            </Box>
          </Box>
        )}

        {/* Instances Tab */}
        {scpActiveTab === 'instances' && (
          <Box>
            <Section title="SCP Instances">
              <Box style={{ marginBottom: '15px' }}>
                <Flex style={{ gap: '10px', marginBottom: '10px' }}>
                  <Box style={{ flex: 1 }}>
                    <input
                      type="text"
                      placeholder="Search SCPs..."
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      style={{
                        width: '100%',
                        padding: '8px',
                        background: 'rgba(0,0,0,0.5)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        color: '#ffffff',
                        fontFamily: 'monospace',
                        fontSize: '12px',
                      }}
                    />
                  </Box>
                  <Box>
                    <select
                      value={filterType}
                      onChange={(e) => setFilterType(e.target.value)}
                      style={{
                        padding: '8px',
                        background: 'rgba(0,0,0,0.5)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        color: '#ffffff',
                        fontFamily: 'monospace',
                        fontSize: '12px',
                      }}
                    >
                      <option value="all">All SCPs</option>
                      <option value="safe">Safe</option>
                      <option value="euclid">Euclid</option>
                      <option value="keter">Keter</option>
                      <option value="thaumiel">Thaumiel</option>
                    </select>
                  </Box>
                  <Button
                    onClick={() => act('scp_add_instance')}
                    icon="plus"
                    size="small"
                    color="green"
                  >
                    Add SCP
                  </Button>
                </Flex>
              </Box>

              <Table>
                <Table.Row header>
                  <Table.Cell>SCP ID</Table.Cell>
                  <Table.Cell>Object Class</Table.Cell>
                  <Table.Cell>Containment Status</Table.Cell>
                  <Table.Cell>Location</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>SCP-173</Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: '#ffaa00', fontWeight: 'bold' }}>
                      EUCLID
                    </Box>
                  </Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: '#66ff66', fontWeight: 'bold' }}>
                      CONTAINED
                    </Box>
                  </Table.Cell>
                  <Table.Cell>Containment Cell A-1</Table.Cell>
                  <Table.Cell>
                    <Flex style={{ gap: '5px' }}>
                      <Button
                        size="small"
                        onClick={() => setSelectedSCP('SCP-173')}
                      >
                        View
                      </Button>
                      <Button
                        size="small"
                        color="blue"
                        onClick={() =>
                          act('scp_edit_instance', { scp: 'SCP-173' })
                        }
                      >
                        Edit
                      </Button>
                    </Flex>
                  </Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>SCP-096</Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: '#ff6666', fontWeight: 'bold' }}>
                      KETER
                    </Box>
                  </Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: '#66ff66', fontWeight: 'bold' }}>
                      CONTAINED
                    </Box>
                  </Table.Cell>
                  <Table.Cell>Containment Cell B-3</Table.Cell>
                  <Table.Cell>
                    <Flex style={{ gap: '5px' }}>
                      <Button
                        size="small"
                        onClick={() => setSelectedSCP('SCP-096')}
                      >
                        View
                      </Button>
                      <Button
                        size="small"
                        color="blue"
                        onClick={() =>
                          act('scp_edit_instance', { scp: 'SCP-096' })
                        }
                      >
                        Edit
                      </Button>
                    </Flex>
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Section>
          </Box>
        )}

        {/* Breaches Tab */}
        {scpActiveTab === 'breaches' && (
          <Box>
            <Section title="Containment Breaches">
              <Table>
                <Table.Row header>
                  <Table.Cell>Breach ID</Table.Cell>
                  <Table.Cell>SCP Involved</Table.Cell>
                  <Table.Cell>Severity</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                {scp_data?.active_breaches > 0 ? (
                  <Table.Row>
                    <Table.Cell>BR-001</Table.Cell>
                    <Table.Cell>SCP-173</Table.Cell>
                    <Table.Cell>
                      <Box style={{ color: '#ff6666', fontWeight: 'bold' }}>
                        CRITICAL
                      </Box>
                    </Table.Cell>
                    <Table.Cell>
                      <Box style={{ color: '#ffaa00', fontWeight: 'bold' }}>
                        ACTIVE
                      </Box>
                    </Table.Cell>
                    <Table.Cell>
                      <Button
                        size="small"
                        color="red"
                        onClick={() => setSelectedBreach('BR-001')}
                      >
                        Respond
                      </Button>
                    </Table.Cell>
                  </Table.Row>
                ) : (
                  <Table.Row>
                    <Table.Cell
                      colSpan={5}
                      style={{ textAlign: 'center', padding: '20px' }}
                    >
                      No active breaches detected. All SCPs are properly
                      contained.
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Section>
          </Box>
        )}

        {/* Research Tab */}
        {scpActiveTab === 'research' && (
          <Box>
            <Section title="SCP Research Projects">
              <Table>
                <Table.Row header>
                  <Table.Cell>Project ID</Table.Cell>
                  <Table.Cell>SCP Subject</Table.Cell>
                  <Table.Cell>Research Type</Table.Cell>
                  <Table.Cell>Progress</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>RES-001</Table.Cell>
                  <Table.Cell>SCP-173</Table.Cell>
                  <Table.Cell>Behavioral Analysis</Table.Cell>
                  <Table.Cell>
                    <ProgressBar value={75} maxValue={100} color="good" />
                  </Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: '#66ff66', fontWeight: 'bold' }}>
                      ONGOING
                    </Box>
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Section>
          </Box>
        )}

        {/* Protocols Tab */}
        {scpActiveTab === 'protocols' && (
          <Box>
            <Section title="Containment Protocols">
              <Table>
                <Table.Row header>
                  <Table.Cell>Protocol ID</Table.Cell>
                  <Table.Cell>SCP Target</Table.Cell>
                  <Table.Cell>Type</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>PROT-173</Table.Cell>
                  <Table.Cell>SCP-173</Table.Cell>
                  <Table.Cell>Standard Containment</Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: '#66ff66', fontWeight: 'bold' }}>
                      ACTIVE
                    </Box>
                  </Table.Cell>
                  <Table.Cell>
                    <Button
                      size="small"
                      color="blue"
                      onClick={() =>
                        act('scp_view_protocol', { protocol: 'PROT-173' })
                      }
                    >
                      View
                    </Button>
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Section>
          </Box>
        )}

        {/* Modals */}
        {selectedSCP && (
          <Modal>
            <Section title={`SCP Details: ${selectedSCP}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>SCP:</strong> {selectedSCP}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> Contained
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Class:</strong> Safe
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  SCP details will be populated from containment data.
                </Box>
              </Box>
              <Button onClick={() => setSelectedSCP(null)}>Close</Button>
            </Section>
          </Modal>
        )}

        {selectedBreach && (
          <Modal>
            <Section title={`Breach Response: ${selectedBreach}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Breach:</strong> {selectedBreach}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> Contained
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Response Time:</strong> Immediate
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  Breach response details will be populated from SCP data.
                </Box>
              </Box>
              <Button onClick={() => setSelectedBreach(null)}>Close</Button>
            </Section>
          </Modal>
        )}

        {/* SCP Status */}
        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            SCP STATUS:
          </Box>
          <Grid style={{ gap: '10px' }}>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {scp_data?.containment_status || 0}%
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  CONTAINMENT STATUS
                </Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {scp_data?.breach_risk || 0}%
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  BREACH RISK
                </Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {scp_data?.research_progress || 0}%
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  RESEARCH PROGRESS
                </Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {scp_data?.security_level || 0}%
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  SECURITY LEVEL
                </Box>
              </Box>
            </Grid.Column>
          </Grid>
        </Box>

        <Box style={{ fontSize: '12px', opacity: 0.7, textAlign: 'center' }}>
          SCP persistence system monitoring containment status, breach risks,
          and research progress.
        </Box>
      </Box>
    );
  };

  // Technology Management Interface
  const TechnologyInterface = ({ techActiveTab, setTechActiveTab }) => {
    const [selectedProject, setSelectedProject] = useLocalState(
      context,
      'techSelectedProject',
      null,
    );
    const [selectedTechnology, setSelectedTechnology] = useLocalState(
      context,
      'techSelectedTechnology',
      null,
    );
    const [searchTerm, setSearchTerm] = useLocalState(
      context,
      'techSearchTerm',
      '',
    );
    const [filterType, setFilterType] = useLocalState(
      context,
      'techFilterType',
      'all',
    );

    return (
      <Box
        style={{
          background: 'rgba(0,0,0,0.7)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: '5px',
          padding: '20px',
          fontFamily: 'monospace',
          fontSize: '14px',
          color: '#ffffff',
          minHeight: '100%',
          position: 'relative',
        }}
      >
        {/* Back to Desktop Button */}
        <Box
          style={{
            position: 'absolute',
            top: '10px',
            right: '10px',
            padding: '8px 16px',
            background: 'rgba(255,255,255,0.1)',
            border: '1px solid rgba(255,255,255,0.3)',
            borderRadius: '5px',
            cursor: 'pointer',
            fontSize: '12px',
            transition: 'all 0.3s ease',
          }}
          onClick={() => setActiveTab('desktop')}
          onMouseEnter={(e) => {
            e.target.style.background = 'rgba(255,255,255,0.2)';
          }}
          onMouseLeave={(e) => {
            e.target.style.background = 'rgba(255,255,255,0.1)';
          }}
        >
          ← BACK TO DESKTOP
        </Box>
        <Box style={{ marginBottom: '20px' }}>
          <Box
            style={{
              fontSize: '24px',
              fontWeight: 'bold',
              marginBottom: '5px',
            }}
          >
            TECHNOLOGY PERSISTENCE
          </Box>
          <Box style={{ fontSize: '16px', opacity: 0.8 }}>
            RESEARCH & DEVELOPMENT
          </Box>
        </Box>

        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
          <Box style={{ textAlign: 'center', marginBottom: '15px' }}>
            TECHNOLOGY PERSISTENCE SYSTEM
          </Box>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
        </Box>

        {/* Technology Controls */}
        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            TECHNOLOGY CONTROLS:
          </Box>
          <Flex wrap="wrap" style={{ gap: '10px', marginBottom: '20px' }}>
            <ActionButton
              action="technology_view_status"
              icon="📊"
              color="blue"
              successMessage="Technology status retrieved"
              tooltip="View technology status"
            >
              VIEW STATUS
            </ActionButton>
            <ActionButton
              action="technology_add_project"
              icon="📋"
              color="purple"
              successMessage="Research project added successfully"
              errorMessage="Failed to add research project"
              tooltip="Add new research project"
            >
              ADD PROJECT
            </ActionButton>
            <EnhancedButton
              icon="⚡"
              color="default"
              onClick={() => setTechnologyModalOpen(true)}
              tooltip="Open detailed technology registration form"
            >
              ADD TECHNOLOGY
            </EnhancedButton>
            <ActionButton
              action="technology_save_data"
              icon="💾"
              color="good"
              successMessage="Technology data saved successfully"
              errorMessage="Failed to save technology data"
              tooltip="Save technology data"
            >
              SAVE DATA
            </ActionButton>
            <EnhancedButton
              icon="🔬"
              color="average"
              onClick={() => {
                addNotification(
                  'Research Analysis',
                  'Analyzing research efficiency...',
                  'info',
                );
                setTimeout(
                  () =>
                    addNotification(
                      'Research Analysis',
                      'Research efficiency optimized',
                      'success',
                    ),
                  2000,
                );
              }}
              tooltip="Analyze research efficiency"
            >
              ANALYZE
            </EnhancedButton>
            <EnhancedButton
              icon="📈"
              color="blue"
              onClick={() => {
                addNotification(
                  'Innovation Boost',
                  'Applying innovation boost...',
                  'info',
                );
                setTimeout(
                  () =>
                    addNotification(
                      'Innovation Boost',
                      'Innovation score increased',
                      'success',
                    ),
                  1500,
                );
              }}
              tooltip="Boost innovation score"
            >
              BOOST
            </EnhancedButton>
          </Flex>
        </Box>

        {/* Technology Status */}
        <Box style={{ lineHeight: '1.6' }}>
          <Box style={{ marginBottom: '10px', fontWeight: 'bold' }}>
            TECHNOLOGY STATUS:
            <DataStatusIndicator data={technology_data} label="TECH" />
          </Box>
          <Box>TECHNOLOGY LEVEL: {technology_data?.technology_level || 0}</Box>
          <Box>
            RESEARCH PROGRESS: {technology_data?.research_progress || 0}%
          </Box>
          <Box>INNOVATION SCORE: {technology_data?.innovation_score || 0}</Box>
          <Box>
            RESEARCH BUDGET: $
            {technology_data?.research_budget
              ? technology_data.research_budget.toLocaleString()
              : '0'}
          </Box>
          <Box>
            RESEARCH EFFICIENCY:{' '}
            {technology_data?.research_efficiency
              ? Math.round(technology_data.research_efficiency * 100)
              : 0}
            %
          </Box>
        </Box>

        {/* Technology Navigation Tabs */}
        <Flex
          style={{
            marginBottom: '20px',
            borderBottom: '1px solid rgba(255,255,255,0.3)',
            gap: '5px',
          }}
        >
          <NavButton
            isActive={techActiveTab === 'overview'}
            onClick={() => setTechActiveTab('overview')}
            icon="📊"
          >
            OVERVIEW
          </NavButton>
          <NavButton
            isActive={techActiveTab === 'projects'}
            onClick={() => setTechActiveTab('projects')}
            icon="📋"
          >
            PROJECTS
          </NavButton>
          <NavButton
            isActive={techActiveTab === 'technologies'}
            onClick={() => setTechActiveTab('technologies')}
            icon="⚡"
          >
            TECHNOLOGIES
          </NavButton>
          <NavButton
            isActive={techActiveTab === 'patents'}
            onClick={() => setTechActiveTab('patents')}
            icon="📄"
          >
            PATENTS
          </NavButton>
          <NavButton
            isActive={techActiveTab === 'budget'}
            onClick={() => setTechActiveTab('budget')}
            icon="💰"
          >
            BUDGET
          </NavButton>
        </Flex>

        {/* Overview Tab */}
        {techActiveTab === 'overview' && (
          <Box>
            <Box
              style={{
                fontSize: '12px',
                opacity: 0.7,
                textAlign: 'center',
                marginTop: '20px',
              }}
            >
              Technology research overview - all systems operational.
            </Box>
          </Box>
        )}

        {/* Projects Tab */}
        {techActiveTab === 'projects' && (
          <Box>
            <Section title="Research Projects">
              <Box style={{ marginBottom: '15px' }}>
                <Flex style={{ gap: '10px', marginBottom: '10px' }}>
                  <Box style={{ flex: 1 }}>
                    <input
                      type="text"
                      placeholder="Search projects..."
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      style={{
                        width: '100%',
                        padding: '8px',
                        background: 'rgba(0,0,0,0.5)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        color: '#ffffff',
                        fontFamily: 'monospace',
                        fontSize: '12px',
                      }}
                    />
                  </Box>
                  <Box>
                    <select
                      value={filterType}
                      onChange={(e) => setFilterType(e.target.value)}
                      style={{
                        padding: '8px',
                        background: 'rgba(0,0,0,0.5)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        color: '#ffffff',
                        fontFamily: 'monospace',
                        fontSize: '12px',
                      }}
                    >
                      <option value="all">All Projects</option>
                      <option value="active">Active</option>
                      <option value="completed">Completed</option>
                      <option value="paused">Paused</option>
                    </select>
                  </Box>
                  <Button
                    onClick={() => act('technology_add_project')}
                    icon="plus"
                    size="small"
                    color="green"
                  >
                    Add Project
                  </Button>
                </Flex>
              </Box>

              <Table>
                <Table.Row header>
                  <Table.Cell>Project ID</Table.Cell>
                  <Table.Cell>Name</Table.Cell>
                  <Table.Cell>Category</Table.Cell>
                  <Table.Cell>Progress</Table.Cell>
                  <Table.Cell>Budget</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>PROJ-001</Table.Cell>
                  <Table.Cell>Advanced Containment Field</Table.Cell>
                  <Table.Cell>Containment Tech</Table.Cell>
                  <Table.Cell>
                    <ProgressBar value={65} maxValue={100} color="good" />
                  </Table.Cell>
                  <Table.Cell>$250,000</Table.Cell>
                  <Table.Cell>
                    <Flex style={{ gap: '5px' }}>
                      <Button
                        size="small"
                        onClick={() => setSelectedProject('PROJ-001')}
                      >
                        View
                      </Button>
                      <Button
                        size="small"
                        color="blue"
                        onClick={() =>
                          act('technology_edit_project', {
                            project: 'PROJ-001',
                          })
                        }
                      >
                        Edit
                      </Button>
                    </Flex>
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Section>
          </Box>
        )}

        {/* Technologies Tab */}
        {techActiveTab === 'technologies' && (
          <Box>
            <Section title="Developed Technologies">
              <Table>
                <Table.Row header>
                  <Table.Cell>Technology ID</Table.Cell>
                  <Table.Cell>Name</Table.Cell>
                  <Table.Cell>Type</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>TECH-001</Table.Cell>
                  <Table.Cell>Quantum Containment Field</Table.Cell>
                  <Table.Cell>Containment</Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: '#66ff66', fontWeight: 'bold' }}>
                      DEPLOYED
                    </Box>
                  </Table.Cell>
                  <Table.Cell>
                    <Button
                      size="small"
                      onClick={() => setSelectedTechnology('TECH-001')}
                    >
                      View
                    </Button>
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Section>
          </Box>
        )}

        {/* Patents Tab */}
        {techActiveTab === 'patents' && (
          <Box>
            <Section title="Patent Portfolio">
              <Table>
                <Table.Row header>
                  <Table.Cell>Patent ID</Table.Cell>
                  <Table.Cell>Title</Table.Cell>
                  <Table.Cell>Filing Date</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>PAT-001</Table.Cell>
                  <Table.Cell>Quantum Containment Method</Table.Cell>
                  <Table.Cell>2024-01-15</Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: '#66ff66', fontWeight: 'bold' }}>
                      APPROVED
                    </Box>
                  </Table.Cell>
                  <Table.Cell>
                    <Button
                      size="small"
                      color="blue"
                      onClick={() =>
                        act('technology_view_patent', { patent: 'PAT-001' })
                      }
                    >
                      View
                    </Button>
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Section>
          </Box>
        )}

        {/* Budget Tab */}
        {techActiveTab === 'budget' && (
          <Box>
            <Section title="Research Budget Management">
              <Grid>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(0,255,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '16px',
                        fontWeight: 'bold',
                        color: '#66ff66',
                      }}
                    >
                      TOTAL BUDGET
                    </Box>
                    <Box style={{ fontSize: '20px' }}>
                      $
                      {technology_data?.research_budget
                        ? technology_data.research_budget.toLocaleString()
                        : '0'}
                    </Box>
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(255,0,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '16px',
                        fontWeight: 'bold',
                        color: '#ff6666',
                      }}
                    >
                      SPENT THIS MONTH
                    </Box>
                    <Box style={{ fontSize: '20px' }}>$125,000</Box>
                  </Box>
                </Grid.Column>
              </Grid>
            </Section>
          </Box>
        )}

        {/* Modals */}
        {selectedProject && (
          <Modal>
            <Section title={`Project Details: ${selectedProject}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Project:</strong> {selectedProject}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> Active
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Progress:</strong> 0%
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  Project details will be populated from technology data.
                </Box>
              </Box>
              <Button onClick={() => setSelectedProject(null)}>Close</Button>
            </Section>
          </Modal>
        )}

        {selectedTechnology && (
          <Modal>
            <Section title={`Technology Details: ${selectedTechnology}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Technology:</strong> {selectedTechnology}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> Active
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Level:</strong> 1
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  Technology details will be populated from technology data.
                </Box>
              </Box>
              <Button onClick={() => setSelectedTechnology(null)}>Close</Button>
            </Section>
          </Modal>
        )}
      </Box>
    );
  };

  // Chemical Management Interface
  const ChemicalInterface = ({ chemicalActiveTab, setChemicalActiveTab }) => {
    return (
      <Box
        style={{
          background: 'rgba(0,0,0,0.7)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: '5px',
          padding: '20px',
          fontFamily: 'monospace',
          fontSize: '14px',
          color: '#ffffff',
          minHeight: '100%',
          position: 'relative',
        }}
      >
        {/* Back to Desktop Button */}
        <Box
          style={{
            position: 'absolute',
            top: '10px',
            right: '10px',
            padding: '8px 16px',
            background: 'rgba(255,255,255,0.1)',
            border: '1px solid rgba(255,255,255,0.3)',
            borderRadius: '5px',
            cursor: 'pointer',
            fontSize: '12px',
            transition: 'all 0.3s ease',
          }}
          onClick={() => setActiveTab('desktop')}
          onMouseEnter={(e) => {
            e.target.style.background = 'rgba(255,255,255,0.2)';
          }}
          onMouseLeave={(e) => {
            e.target.style.background = 'rgba(255,255,255,0.1)';
          }}
        >
          ← BACK TO DESKTOP
        </Box>
        <Box style={{ marginBottom: '20px' }}>
          <Box
            style={{
              fontSize: '24px',
              fontWeight: 'bold',
              marginBottom: '5px',
            }}
          >
            CHEMICAL PERSISTENCE
          </Box>
          <Box style={{ fontSize: '16px', opacity: 0.8 }}>
            RESEARCH & CONTAINMENT
          </Box>
        </Box>

        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
          <Box style={{ textAlign: 'center', marginBottom: '15px' }}>
            CHEMICAL PERSISTENCE SYSTEM
          </Box>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
        </Box>

        {/* Chemical Controls */}
        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            CHEMICAL CONTROLS:
          </Box>
          <Flex wrap="wrap" style={{ gap: '10px', marginBottom: '20px' }}>
            <Button
              onClick={() => act('chemical_view_records')}
              style={{
                background: 'rgba(255,255,255,0.1)',
                border: '1px solid rgba(255,255,255,0.3)',
                color: '#ffffff',
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '8px 16px',
                cursor: 'pointer',
              }}
            >
              VIEW RECORDS
            </Button>
            <Button
              onClick={() => act('chemical_add_research')}
              style={{
                background: 'rgba(255,255,255,0.1)',
                border: '1px solid rgba(255,255,255,0.3)',
                color: '#ffffff',
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '8px 16px',
                cursor: 'pointer',
              }}
            >
              ADD RESEARCH
            </Button>
            <Button
              onClick={() => act('chemical_containment_status')}
              style={{
                background: 'rgba(255,255,255,0.1)',
                border: '1px solid rgba(255,255,255,0.3)',
                color: '#ffffff',
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '8px 16px',
                cursor: 'pointer',
              }}
            >
              CONTAINMENT STATUS
            </Button>
          </Flex>
        </Box>

        {/* Chemical Status */}
        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            CHEMICAL STATUS:
          </Box>
          <Grid style={{ gap: '10px' }}>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {chemical_data?.total_compounds_discovered || 0}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  COMPOUNDS DISCOVERED
                </Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {chemical_data?.active_containment_breaches || 0}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  ACTIVE BREACHES
                </Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {chemical_data?.chemical_research_progress || 0}%
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  RESEARCH PROGRESS
                </Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {chemical_data?.containment_effectiveness || 100}%
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  CONTAINMENT EFFECTIVENESS
                </Box>
              </Box>
            </Grid.Column>
          </Grid>
        </Box>

        <Box style={{ fontSize: '12px', opacity: 0.7, textAlign: 'center' }}>
          Chemical persistence system monitoring active compounds, research
          projects, and containment protocols.
        </Box>
      </Box>
    );
  };

  // Incident Management Interface
  const IncidentInterface = ({ incidentActiveTab, setIncidentActiveTab }) => {
    return (
      <Box
        style={{
          background: 'rgba(0,0,0,0.7)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: '5px',
          padding: '20px',
          fontFamily: 'monospace',
          fontSize: '14px',
          color: '#ffffff',
          minHeight: '100%',
          position: 'relative',
        }}
      >
        {/* Back to Desktop Button */}
        <Box
          style={{
            position: 'absolute',
            top: '10px',
            right: '10px',
            padding: '8px 16px',
            background: 'rgba(255,255,255,0.1)',
            border: '1px solid rgba(255,255,255,0.3)',
            borderRadius: '5px',
            cursor: 'pointer',
            fontSize: '12px',
            transition: 'all 0.3s ease',
          }}
          onClick={() => setActiveTab('desktop')}
          onMouseEnter={(e) => {
            e.target.style.background = 'rgba(255,255,255,0.2)';
          }}
          onMouseLeave={(e) => {
            e.target.style.background = 'rgba(255,255,255,0.1)';
          }}
        >
          ← BACK TO DESKTOP
        </Box>
        <Box style={{ marginBottom: '20px' }}>
          <Box
            style={{
              fontSize: '24px',
              fontWeight: 'bold',
              marginBottom: '5px',
            }}
          >
            INCIDENT PERSISTENCE
          </Box>
          <Box style={{ fontSize: '16px', opacity: 0.8 }}>
            BREACHES & RESPONSES
          </Box>
        </Box>

        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
          <Box style={{ textAlign: 'center', marginBottom: '15px' }}>
            INCIDENT PERSISTENCE SYSTEM
          </Box>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
        </Box>

        {/* Incident Controls */}
        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            INCIDENT CONTROLS:
          </Box>
          <Flex wrap="wrap" style={{ gap: '10px', marginBottom: '20px' }}>
            <Button
              onClick={() => act('incident_view_logs')}
              style={{
                background: 'rgba(255,255,255,0.1)',
                border: '1px solid rgba(255,255,255,0.3)',
                color: '#ffffff',
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '8px 16px',
                cursor: 'pointer',
              }}
            >
              VIEW LOGS
            </Button>
            <Button
              onClick={() => act('incident_add_breach')}
              style={{
                background: 'rgba(255,255,255,0.1)',
                border: '1px solid rgba(255,255,255,0.3)',
                color: '#ffffff',
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '8px 16px',
                cursor: 'pointer',
              }}
            >
              ADD BREACH
            </Button>
            <Button
              onClick={() => act('incident_response_teams')}
              style={{
                background: 'rgba(255,255,255,0.1)',
                border: '1px solid rgba(255,255,255,0.3)',
                color: '#ffffff',
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '8px 16px',
                cursor: 'pointer',
              }}
            >
              RESPONSE TEAMS
            </Button>
          </Flex>
        </Box>

        {/* Incident Status */}
        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            INCIDENT STATUS:
          </Box>
          <Grid style={{ gap: '10px' }}>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {incident_data?.total_incidents || 0}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  TOTAL INCIDENTS
                </Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {incident_data?.active_incidents || 0}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  ACTIVE INCIDENTS
                </Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {incident_data?.average_response_time || 0}m
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  AVG RESPONSE TIME
                </Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {incident_data?.containment_success_rate || 100}%
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  SUCCESS RATE
                </Box>
              </Box>
            </Grid.Column>
          </Grid>
        </Box>

        <Box style={{ fontSize: '12px', opacity: 0.7, textAlign: 'center' }}>
          Incident persistence system tracking breaches, response times, and
          containment effectiveness.
        </Box>
      </Box>
    );
  };

  // Psychological Management Interface
  const PsychologicalInterface = ({
    psychologicalActiveTab,
    setPsychologicalActiveTab,
  }) => {
    return (
      <Box
        style={{
          background: 'rgba(0,0,0,0.7)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: '5px',
          padding: '20px',
          fontFamily: 'monospace',
          fontSize: '14px',
          color: '#ffffff',
          minHeight: '100%',
          position: 'relative',
        }}
      >
        {/* Back to Desktop Button */}
        <Box
          style={{
            position: 'absolute',
            top: '10px',
            right: '10px',
            padding: '8px 16px',
            background: 'rgba(255,255,255,0.1)',
            border: '1px solid rgba(255,255,255,0.3)',
            borderRadius: '5px',
            cursor: 'pointer',
            fontSize: '12px',
            transition: 'all 0.3s ease',
          }}
          onClick={() => setActiveTab('desktop')}
          onMouseEnter={(e) => {
            e.target.style.background = 'rgba(255,255,255,0.2)';
          }}
          onMouseLeave={(e) => {
            e.target.style.background = 'rgba(255,255,255,0.1)';
          }}
        >
          ← BACK TO DESKTOP
        </Box>
        <Box style={{ marginBottom: '20px' }}>
          <Box
            style={{
              fontSize: '24px',
              fontWeight: 'bold',
              marginBottom: '5px',
            }}
          >
            PSYCHOLOGICAL PERSISTENCE
          </Box>
          <Box style={{ fontSize: '16px', opacity: 0.8 }}>
            MENTAL HEALTH & THERAPY
          </Box>
        </Box>

        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
          <Box style={{ textAlign: 'center', marginBottom: '15px' }}>
            PSYCHOLOGICAL PERSISTENCE SYSTEM
          </Box>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
        </Box>

        {/* Psychological Controls */}
        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            PSYCHOLOGICAL CONTROLS:
          </Box>
          <Flex wrap="wrap" style={{ gap: '10px', marginBottom: '20px' }}>
            <Button
              onClick={() => act('psychological_view_records')}
              style={{
                background: 'rgba(255,255,255,0.1)',
                border: '1px solid rgba(255,255,255,0.3)',
                color: '#ffffff',
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '8px 16px',
                cursor: 'pointer',
              }}
            >
              VIEW RECORDS
            </Button>
            <Button
              onClick={() => act('psychological_add_session')}
              style={{
                background: 'rgba(255,255,255,0.1)',
                border: '1px solid rgba(255,255,255,0.3)',
                color: '#ffffff',
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '8px 16px',
                cursor: 'pointer',
              }}
            >
              ADD SESSION
            </Button>
            <Button
              onClick={() => act('psychological_assessments')}
              style={{
                background: 'rgba(255,255,255,0.1)',
                border: '1px solid rgba(255,255,255,0.3)',
                color: '#ffffff',
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '8px 16px',
                cursor: 'pointer',
              }}
            >
              ASSESSMENTS
            </Button>
          </Flex>
        </Box>

        {/* Psychological Status */}
        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            PSYCHOLOGICAL STATUS:
          </Box>
          <Grid style={{ gap: '10px' }}>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {psychological_data?.total_staff_assessed || 0}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  STAFF ASSESSED
                </Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {psychological_data?.average_mental_health || 100}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  AVG MENTAL HEALTH
                </Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {psychological_data?.therapy_success_rate || 100}%
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  THERAPY SUCCESS
                </Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {psychological_data?.scp_exposure_cases || 0}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  SCP EXPOSURE CASES
                </Box>
              </Box>
            </Grid.Column>
          </Grid>
        </Box>

        <Box style={{ fontSize: '12px', opacity: 0.7, textAlign: 'center' }}>
          Psychological persistence system monitoring mental health, therapy
          sessions, and SCP exposure effects.
        </Box>
      </Box>
    );
  };

  // Infrastructure Management Interface
  const InfrastructureInterface = ({
    infrastructureActiveTab,
    setInfrastructureActiveTab,
  }) => {
    return (
      <Box
        style={{
          background: 'rgba(0,0,0,0.7)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: '5px',
          padding: '20px',
          fontFamily: 'monospace',
          fontSize: '14px',
          color: '#ffffff',
          minHeight: '100%',
          position: 'relative',
        }}
      >
        {/* Back to Desktop Button */}
        <Box
          style={{
            position: 'absolute',
            top: '10px',
            right: '10px',
            padding: '8px 16px',
            background: 'rgba(255,255,255,0.1)',
            border: '1px solid rgba(255,255,255,0.3)',
            borderRadius: '5px',
            cursor: 'pointer',
            fontSize: '12px',
            transition: 'all 0.3s ease',
          }}
          onClick={() => setActiveTab('desktop')}
          onMouseEnter={(e) => {
            e.target.style.background = 'rgba(255,255,255,0.2)';
          }}
          onMouseLeave={(e) => {
            e.target.style.background = 'rgba(255,255,255,0.1)';
          }}
        >
          ← BACK TO DESKTOP
        </Box>
        <Box style={{ marginBottom: '20px' }}>
          <Box
            style={{
              fontSize: '24px',
              fontWeight: 'bold',
              marginBottom: '5px',
            }}
          >
            INFRASTRUCTURE PERSISTENCE
          </Box>
          <Box style={{ fontSize: '16px', opacity: 0.8 }}>
            MAINTENANCE & SYSTEMS
          </Box>
        </Box>

        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
          <Box style={{ textAlign: 'center', marginBottom: '15px' }}>
            INFRASTRUCTURE PERSISTENCE SYSTEM
          </Box>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
        </Box>

        {/* Infrastructure Controls */}
        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            INFRASTRUCTURE CONTROLS:
          </Box>
          <Flex wrap="wrap" style={{ gap: '10px', marginBottom: '20px' }}>
            <ActionButton
              action="infrastructure_view_status"
              icon="📊"
              color="blue"
              successMessage="Infrastructure status retrieved"
              tooltip="View infrastructure status"
            >
              VIEW STATUS
            </ActionButton>
            <ActionButton
              action="infrastructure_add_maintenance"
              icon="🔧"
              color="average"
              successMessage="Maintenance task added successfully"
              errorMessage="Failed to add maintenance task"
              tooltip="Add maintenance task"
            >
              ADD MAINTENANCE
            </ActionButton>
            <ActionButton
              action="infrastructure_power_systems"
              icon="⚡"
              color="purple"
              successMessage="Power systems status retrieved"
              tooltip="Check power systems"
            >
              POWER SYSTEMS
            </ActionButton>
            <ActionButton
              action="infrastructure_save_data"
              icon="💾"
              color="good"
              successMessage="Infrastructure data saved successfully"
              errorMessage="Failed to save infrastructure data"
              tooltip="Save infrastructure data"
            >
              SAVE DATA
            </ActionButton>
            <ActionButton
              action="infrastructure_load_data"
              icon="📂"
              color="default"
              successMessage="Infrastructure data loaded successfully"
              errorMessage="Failed to load infrastructure data"
              tooltip="Load infrastructure data"
            >
              LOAD DATA
            </ActionButton>
            <EnhancedButton
              icon="🔍"
              color="blue"
              onClick={() => {
                addNotification(
                  'System Scan',
                  'Scanning infrastructure systems...',
                  'info',
                );
                setTimeout(
                  () =>
                    addNotification(
                      'System Scan',
                      'Infrastructure scan completed',
                      'success',
                    ),
                  3000,
                );
              }}
              tooltip="Scan infrastructure systems"
            >
              SYSTEM SCAN
            </EnhancedButton>
            <EnhancedButton
              icon="🏗️"
              color="average"
              onClick={() => {
                addNotification(
                  'Construction',
                  'Checking construction projects...',
                  'info',
                );
                setTimeout(
                  () =>
                    addNotification(
                      'Construction',
                      'Construction projects updated',
                      'success',
                    ),
                  2000,
                );
              }}
              tooltip="Check construction projects"
            >
              CONSTRUCTION
            </EnhancedButton>
          </Flex>
        </Box>

        {/* Infrastructure Status */}
        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            INFRASTRUCTURE STATUS:
          </Box>
          <Grid style={{ gap: '10px' }}>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {infrastructure_data?.total_equipment || 0}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  TOTAL EQUIPMENT
                </Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {infrastructure_data?.operational_equipment || 0}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  OPERATIONAL
                </Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {infrastructure_data?.power_efficiency || 100}%
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  POWER EFFICIENCY
                </Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {infrastructure_data?.structural_health || 100}%
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  STRUCTURAL HEALTH
                </Box>
              </Box>
            </Grid.Column>
          </Grid>
        </Box>

        <Box style={{ fontSize: '12px', opacity: 0.7, textAlign: 'center' }}>
          Infrastructure persistence system monitoring equipment status, power
          systems, and structural integrity.
        </Box>
      </Box>
    );
  };

  // Analytics Management Interface
  const AnalyticsInterface = ({
    analyticsActiveTab,
    setAnalyticsActiveTab,
  }) => {
    return (
      <Box
        style={{
          background: 'rgba(0,0,0,0.7)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: '5px',
          padding: '20px',
          fontFamily: 'monospace',
          fontSize: '14px',
          color: '#ffffff',
          minHeight: '100%',
          position: 'relative',
        }}
      >
        {/* Back to Desktop Button */}
        <Box
          style={{
            position: 'absolute',
            top: '10px',
            right: '10px',
            padding: '8px 16px',
            background: 'rgba(255,255,255,0.1)',
            border: '1px solid rgba(255,255,255,0.3)',
            borderRadius: '5px',
            cursor: 'pointer',
            fontSize: '12px',
            transition: 'all 0.3s ease',
          }}
          onClick={() => setActiveTab('desktop')}
          onMouseEnter={(e) => {
            e.target.style.background = 'rgba(255,255,255,0.2)';
          }}
          onMouseLeave={(e) => {
            e.target.style.background = 'rgba(255,255,255,0.1)';
          }}
        >
          ← BACK TO DESKTOP
        </Box>
        <Box style={{ marginBottom: '20px' }}>
          <Box
            style={{
              fontSize: '24px',
              fontWeight: 'bold',
              marginBottom: '5px',
            }}
          >
            ANALYTICS PERSISTENCE
          </Box>
          <Box style={{ fontSize: '16px', opacity: 0.8 }}>
            PERFORMANCE & METRICS
          </Box>
        </Box>

        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
          <Box style={{ textAlign: 'center', marginBottom: '15px' }}>
            ANALYTICS PERSISTENCE SYSTEM
          </Box>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
        </Box>

        {/* Analytics Controls */}
        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            ANALYTICS CONTROLS:
          </Box>
          <Flex wrap="wrap" style={{ gap: '10px', marginBottom: '20px' }}>
            <ActionButton
              action="analytics_view_metrics"
              icon="📊"
              color="blue"
              successMessage="Analytics metrics retrieved"
              tooltip="View analytics metrics"
            >
              VIEW METRICS
            </ActionButton>
            <EnhancedButton
              icon="📄"
              color="purple"
              onClick={() => setAnalyticsReportModalOpen(true)}
              tooltip="Open detailed analytics report generation form"
            >
              GENERATE REPORT
            </EnhancedButton>
            <EnhancedButton
              icon="📈"
              color="average"
              onClick={() => setAnalyticsKpiModalOpen(true)}
              tooltip="Open detailed KPI dashboard configuration form"
            >
              KPI DASHBOARD
            </EnhancedButton>
            <ActionButton
              action="analytics_save_data"
              icon="💾"
              color="good"
              successMessage="Analytics data saved successfully"
              errorMessage="Failed to save analytics data"
              tooltip="Save analytics data"
            >
              SAVE DATA
            </ActionButton>
            <ActionButton
              action="analytics_load_data"
              icon="📂"
              color="default"
              successMessage="Analytics data loaded successfully"
              errorMessage="Failed to load analytics data"
              tooltip="Load analytics data"
            >
              LOAD DATA
            </ActionButton>
            <EnhancedButton
              icon="🔍"
              color="blue"
              onClick={() => {
                addNotification(
                  'Data Analysis',
                  'Analyzing performance data...',
                  'info',
                );
                setTimeout(
                  () =>
                    addNotification(
                      'Data Analysis',
                      'Performance analysis completed',
                      'success',
                    ),
                  2500,
                );
              }}
              tooltip="Analyze performance data"
            >
              ANALYZE
            </EnhancedButton>
            <EnhancedButton
              icon="📤"
              color="purple"
              onClick={() => {
                addNotification(
                  'Export',
                  'Exporting analytics data...',
                  'info',
                );
                setTimeout(
                  () =>
                    addNotification(
                      'Export',
                      'Analytics data exported successfully',
                      'success',
                    ),
                  1500,
                );
              }}
              tooltip="Export analytics data"
            >
              EXPORT
            </EnhancedButton>
          </Flex>
        </Box>

        {/* Analytics Status */}
        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            ANALYTICS STATUS:
          </Box>
          <Grid style={{ gap: '10px' }}>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {analytics_data?.overall_efficiency || 100}%
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  OVERALL EFFICIENCY
                </Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {analytics_data?.performance_score || 100}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  PERFORMANCE SCORE
                </Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {analytics_data?.trend_direction || 'STABLE'}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  TREND DIRECTION
                </Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {analytics_data?.data_quality_score || 100}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  DATA QUALITY
                </Box>
              </Box>
            </Grid.Column>
          </Grid>
        </Box>

        <Box style={{ fontSize: '12px', opacity: 0.7, textAlign: 'center' }}>
          Analytics persistence system tracking performance metrics, efficiency
          data, and statistical analysis.
        </Box>
      </Box>
    );
  };

  // Player Data Management Interface
  const PlayerInterface = ({ playerActiveTab, setPlayerActiveTab }) => {
    const [selectedPlayer, setSelectedPlayer] = useLocalState(
      context,
      'playerSelectedPlayer',
      null,
    );
    const [selectedFaction, setSelectedFaction] = useLocalState(
      context,
      'playerSelectedFaction',
      null,
    );
    const [searchTerm, setSearchTerm] = useLocalState(
      context,
      'playerSearchTerm',
      '',
    );
    const [filterType, setFilterType] = useLocalState(
      context,
      'playerFilterType',
      'all',
    );

    return (
      <Box
        style={{
          background: 'rgba(0,0,0,0.7)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: '5px',
          padding: '20px',
          fontFamily: 'monospace',
          fontSize: '14px',
          color: '#ffffff',
          minHeight: '100%',
          position: 'relative',
        }}
      >
        {/* Back to Desktop Button */}
        <Box
          style={{
            position: 'absolute',
            top: '10px',
            right: '10px',
            padding: '8px 16px',
            background: 'rgba(255,255,255,0.1)',
            border: '1px solid rgba(255,255,255,0.3)',
            borderRadius: '5px',
            cursor: 'pointer',
            fontSize: '12px',
            transition: 'all 0.3s ease',
          }}
          onClick={() => setActiveTab('desktop')}
          onMouseEnter={(e) => {
            e.target.style.background = 'rgba(255,255,255,0.2)';
          }}
          onMouseLeave={(e) => {
            e.target.style.background = 'rgba(255,255,255,0.1)';
          }}
        >
          ← BACK TO DESKTOP
        </Box>
        <Box style={{ marginBottom: '20px' }}>
          <Box
            style={{
              fontSize: '24px',
              fontWeight: 'bold',
              marginBottom: '5px',
            }}
          >
            PLAYER PERSISTENCE
          </Box>
          <Box style={{ fontSize: '16px', opacity: 0.8 }}>
            PROGRESSION & ACHIEVEMENTS
          </Box>
        </Box>

        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
          <Box style={{ textAlign: 'center', marginBottom: '15px' }}>
            PLAYER PERSISTENCE SYSTEM
          </Box>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
        </Box>

        {/* Player Controls */}
        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            PLAYER CONTROLS:
          </Box>
          <Flex wrap="wrap" style={{ gap: '10px', marginBottom: '20px' }}>
            <Button
              onClick={() => act('player_view_data')}
              style={{
                background: 'rgba(255,255,255,0.1)',
                border: '1px solid rgba(255,255,255,0.3)',
                color: '#ffffff',
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '8px 16px',
                cursor: 'pointer',
              }}
            >
              VIEW DATA
            </Button>
            <Button
              onClick={() => act('player_export_data')}
              style={{
                background: 'rgba(255,255,255,0.1)',
                border: '1px solid rgba(255,255,255,0.3)',
                color: '#ffffff',
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '8px 16px',
                cursor: 'pointer',
              }}
            >
              EXPORT DATA
            </Button>
            <Button
              onClick={() => act('player_reset_progress')}
              style={{
                background: 'rgba(255,0,0,0.2)',
                border: '1px solid rgba(255,0,0,0.5)',
                color: '#ff6666',
                fontFamily: 'monospace',
                fontSize: '12px',
                padding: '8px 16px',
                cursor: 'pointer',
              }}
            >
              RESET PROGRESS
            </Button>
          </Flex>
        </Box>

        {/* Player Status */}
        <Box style={{ lineHeight: '1.6' }}>
          <Box style={{ marginBottom: '10px', fontWeight: 'bold' }}>
            PLAYER STATUS:
            <DataStatusIndicator data={player_data} label="PLAYER" />
          </Box>
          <Box>ACTIVE PLAYERS: {player_data?.active_players || 0}</Box>
          <Box>TOTAL EXPERIENCE: {player_data?.total_experience || 0}</Box>
          <Box>
            AVERAGE RANK:{' '}
            {player_data?.average_rank
              ? player_data.average_rank.toFixed(1)
              : '0.0'}
          </Box>
          <Box>
            ACHIEVEMENTS UNLOCKED: {player_data?.achievements_unlocked || 0}
          </Box>
          <Box>
            DATABASE STATUS:{' '}
            {system_status === 'operational' ? 'CONNECTED' : 'DISCONNECTED'}
          </Box>
        </Box>

        {/* Player Navigation Tabs */}
        <Flex
          style={{
            marginBottom: '20px',
            borderBottom: '1px solid rgba(255,255,255,0.3)',
            gap: '5px',
          }}
        >
          <NavButton
            isActive={playerActiveTab === 'overview'}
            onClick={() => setPlayerActiveTab('overview')}
            icon="📊"
          >
            OVERVIEW
          </NavButton>
          <NavButton
            isActive={playerActiveTab === 'players'}
            onClick={() => setPlayerActiveTab('players')}
            icon="👥"
          >
            PLAYERS
          </NavButton>
          <NavButton
            isActive={playerActiveTab === 'factions'}
            onClick={() => setPlayerActiveTab('factions')}
            icon="⚔️"
          >
            FACTIONS
          </NavButton>
          <NavButton
            isActive={playerActiveTab === 'achievements'}
            onClick={() => setPlayerActiveTab('achievements')}
            icon="🏆"
          >
            ACHIEVEMENTS
          </NavButton>
          <NavButton
            isActive={playerActiveTab === 'analytics'}
            onClick={() => setPlayerActiveTab('analytics')}
            icon="📈"
          >
            ANALYTICS
          </NavButton>
        </Flex>

        {/* Overview Tab */}
        {playerActiveTab === 'overview' && (
          <Box>
            <Section title="Player Progression Overview">
              <Grid>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(255,255,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#ffff66',
                      }}
                    >
                      ACTIVE PLAYERS
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {player_data?.active_players || 0}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>Online</Box>
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(0,255,255,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#66ffff',
                      }}
                    >
                      TOTAL EXPERIENCE
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {player_data?.total_experience || 0}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>Points</Box>
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(255,0,255,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#ff66ff',
                      }}
                    >
                      AVERAGE RANK
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {player_data?.average_rank
                        ? player_data.average_rank.toFixed(1)
                        : '0.0'}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>Level</Box>
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(0,255,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '18px',
                        fontWeight: 'bold',
                        color: '#66ff66',
                      }}
                    >
                      ACHIEVEMENTS
                    </Box>
                    <Box style={{ fontSize: '24px' }}>
                      {player_data?.achievements_unlocked || 0}
                    </Box>
                    <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                      Unlocked
                    </Box>
                  </Box>
                </Grid.Column>
              </Grid>
            </Section>
          </Box>
        )}

        {/* Players Tab */}
        {playerActiveTab === 'players' && (
          <Box>
            <Section title="Player Management">
              <Box style={{ marginBottom: '15px' }}>
                <Flex style={{ gap: '10px', marginBottom: '10px' }}>
                  <Box style={{ flex: 1 }}>
                    <input
                      type="text"
                      placeholder="Search players..."
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      style={{
                        width: '100%',
                        padding: '8px',
                        background: 'rgba(0,0,0,0.5)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        color: '#ffffff',
                        fontFamily: 'monospace',
                        fontSize: '12px',
                      }}
                    />
                  </Box>
                  <Box>
                    <select
                      value={filterType}
                      onChange={(e) => setFilterType(e.target.value)}
                      style={{
                        padding: '8px',
                        background: 'rgba(0,0,0,0.5)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        color: '#ffffff',
                        fontFamily: 'monospace',
                        fontSize: '12px',
                      }}
                    >
                      <option value="all">All Players</option>
                      <option value="online">Online</option>
                      <option value="offline">Offline</option>
                      <option value="admin">Administrators</option>
                    </select>
                  </Box>
                  <Button
                    onClick={() => act('player_add_player')}
                    icon="plus"
                    size="small"
                    color="green"
                  >
                    Add Player
                  </Button>
                </Flex>
              </Box>

              <Table>
                <Table.Row header>
                  <Table.Cell>Player ID</Table.Cell>
                  <Table.Cell>Username</Table.Cell>
                  <Table.Cell>Rank</Table.Cell>
                  <Table.Cell>Faction</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>PLAYER-001</Table.Cell>
                  <Table.Cell>DrSmith</Table.Cell>
                  <Table.Cell>Senior Researcher</Table.Cell>
                  <Table.Cell>Foundation</Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: '#66ff66', fontWeight: 'bold' }}>
                      ONLINE
                    </Box>
                  </Table.Cell>
                  <Table.Cell>
                    <Flex style={{ gap: '5px' }}>
                      <Button
                        size="small"
                        onClick={() => setSelectedPlayer('PLAYER-001')}
                      >
                        View
                      </Button>
                      <Button
                        size="small"
                        color="blue"
                        onClick={() =>
                          act('player_edit_player', { player: 'PLAYER-001' })
                        }
                      >
                        Edit
                      </Button>
                    </Flex>
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Section>
          </Box>
        )}

        {/* Factions Tab */}
        {playerActiveTab === 'factions' && (
          <Box>
            <Section title="Faction Management">
              <Table>
                <Table.Row header>
                  <Table.Cell>Faction ID</Table.Cell>
                  <Table.Cell>Name</Table.Cell>
                  <Table.Cell>Members</Table.Cell>
                  <Table.Cell>Influence</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>FAC-001</Table.Cell>
                  <Table.Cell>SCP Foundation</Table.Cell>
                  <Table.Cell>45</Table.Cell>
                  <Table.Cell>
                    <ProgressBar value={85} maxValue={100} color="good" />
                  </Table.Cell>
                  <Table.Cell>
                    <Box style={{ color: '#66ff66', fontWeight: 'bold' }}>
                      ACTIVE
                    </Box>
                  </Table.Cell>
                  <Table.Cell>
                    <Button
                      size="small"
                      onClick={() => setSelectedFaction('FAC-001')}
                    >
                      View
                    </Button>
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Section>
          </Box>
        )}

        {/* Achievements Tab */}
        {playerActiveTab === 'achievements' && (
          <Box>
            <Section title="Achievement System">
              <Table>
                <Table.Row header>
                  <Table.Cell>Achievement ID</Table.Cell>
                  <Table.Cell>Name</Table.Cell>
                  <Table.Cell>Description</Table.Cell>
                  <Table.Cell>Unlocked By</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>ACH-001</Table.Cell>
                  <Table.Cell>First Containment</Table.Cell>
                  <Table.Cell>
                    Successfully contain an SCP for the first time
                  </Table.Cell>
                  <Table.Cell>12 players</Table.Cell>
                  <Table.Cell>
                    <Button
                      size="small"
                      color="blue"
                      onClick={() =>
                        act('player_view_achievement', {
                          achievement: 'ACH-001',
                        })
                      }
                    >
                      View
                    </Button>
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Section>
          </Box>
        )}

        {/* Analytics Tab */}
        {playerActiveTab === 'analytics' && (
          <Box>
            <Section title="Player Analytics">
              <Grid>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(255,0,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '16px',
                        fontWeight: 'bold',
                        color: '#ff6666',
                      }}
                    >
                      DAILY ACTIVE USERS
                    </Box>
                    <Box style={{ fontSize: '20px' }}>23</Box>
                  </Box>
                </Grid.Column>
                <Grid.Column size={6}>
                  <Box
                    style={{
                      background: 'rgba(0,255,0,0.1)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '16px',
                        fontWeight: 'bold',
                        color: '#66ff66',
                      }}
                    >
                      MONTHLY RETENTION
                    </Box>
                    <Box style={{ fontSize: '20px' }}>78%</Box>
                  </Box>
                </Grid.Column>
              </Grid>
            </Section>
          </Box>
        )}

        {/* Modals */}
        {selectedPlayer && (
          <Modal>
            <Section title={`Player Details: ${selectedPlayer}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Player:</strong> {selectedPlayer}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> Online
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Rank:</strong> Staff
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  Player details will be populated from player data.
                </Box>
              </Box>
              <Button onClick={() => setSelectedPlayer(null)}>Close</Button>
            </Section>
          </Modal>
        )}

        {selectedFaction && (
          <Modal>
            <Section title={`Faction Details: ${selectedFaction}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Faction:</strong> {selectedFaction}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> Active
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Members:</strong> 0
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  Faction details will be populated from player data.
                </Box>
              </Box>
              <Button onClick={() => setSelectedFaction(null)}>Close</Button>
            </Section>
          </Modal>
        )}

        {/* Technology Status */}
        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            TECHNOLOGY STATUS:
          </Box>
          <Grid style={{ gap: '10px' }}>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {technology_data?.total_projects || 0}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  TOTAL PROJECTS
                </Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {technology_data?.active_projects || 0}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  ACTIVE PROJECTS
                </Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {technology_data?.research_efficiency || 0}%
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  RESEARCH EFFICIENCY
                </Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {technology_data?.breakthroughs || 0}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  BREAKTHROUGHS
                </Box>
              </Box>
            </Grid.Column>
          </Grid>
        </Box>

        <Box style={{ fontSize: '12px', opacity: 0.7, textAlign: 'center' }}>
          Technology persistence system tracking research projects, development
          progress, and breakthroughs.
        </Box>
      </Box>
    );
  };

  // Medical Management Interface
  const MedicalInterface = ({ medicalActiveTab, setMedicalActiveTab }) => {
    console.log('MedicalInterface: Component is being rendered');
    console.log('MedicalInterface: selectedOutbreak =', selectedOutbreak);
    const [selectedPatient, setSelectedPatient] = React.useState(null);
    const [selectedTreatment, setSelectedTreatment] = React.useState(null);
    const [selectedOutbreak, setSelectedOutbreak] = React.useState(null);
    console.log(
      'MedicalInterface: After useState, selectedOutbreak =',
      selectedOutbreak,
    );
    const [selectedProject, setSelectedProject] = React.useState(null);

    const [searchTerm, setSearchTerm] = useLocalState(
      context,
      'medicalSearchTerm',
      '',
    );
    const [filterType, setFilterType] = useLocalState(
      context,
      'medicalFilterType',
      'all',
    );
    const [sortBy, setSortBy] = useLocalState(context, 'medicalSortBy', 'name');
    const [sortOrder, setSortOrder] = useLocalState(
      context,
      'medicalSortOrder',
      'asc',
    );

    // Don't render the modal if selectedOutbreak is "medical"
    const shouldShowOutbreakModal =
      selectedOutbreak && selectedOutbreak !== 'medical';
    console.log(
      'MedicalInterface: shouldShowOutbreakModal =',
      shouldShowOutbreakModal,
    );
    console.log('MedicalInterface: selectedTreatment =', selectedTreatment);
    console.log('MedicalInterface: selectedPatient =', selectedPatient);
    console.log('MedicalInterface: medicalActiveTab =', medicalActiveTab);

    // Use raw state values directly - no effective value logic
    const effectiveActiveTab = medicalActiveTab;
    const effectiveSelectedOutbreak = selectedOutbreak;
    const effectiveSelectedTreatment = selectedTreatment;
    const effectiveSelectedPatient = selectedPatient;
    const effectiveSelectedProject = selectedProject;

    // Debug logging for sub-tab issues
    console.log('MedicalInterface: effectiveActiveTab =', effectiveActiveTab);
    console.log('MedicalInterface: medicalActiveTab =', medicalActiveTab);

    // No useEffect - handle "medical" values gracefully in render logic

    return (
      <Box
        style={{
          background: 'rgba(0,0,0,0.7)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: '5px',
          padding: '20px',
          fontFamily: 'monospace',
          fontSize: '14px',
          color: '#ffffff',
          minHeight: '100%',
          position: 'relative',
        }}
      >
        {/* Back to Desktop Button */}
        <Box
          style={{
            position: 'absolute',
            top: '10px',
            right: '10px',
            padding: '8px 16px',
            background: 'rgba(255,255,255,0.1)',
            border: '1px solid rgba(255,255,255,0.3)',
            borderRadius: '5px',
            cursor: 'pointer',
            fontSize: '12px',
            transition: 'all 0.3s ease',
          }}
          onClick={() => setActiveTab('desktop')}
          onMouseEnter={(e) => {
            e.target.style.background = 'rgba(255,255,255,0.2)';
          }}
          onMouseLeave={(e) => {
            e.target.style.background = 'rgba(255,255,255,0.1)';
          }}
        >
          ← BACK TO DESKTOP
        </Box>
        {/* Debug: Simple test to see if component renders */}
        <Box
          style={{ color: 'yellow', fontSize: '12px', marginBottom: '10px' }}
        >
          MedicalInterface: Component is rendering
        </Box>
        <Box style={{ marginBottom: '20px' }}>
          <Box
            style={{
              fontSize: '24px',
              fontWeight: 'bold',
              marginBottom: '5px',
            }}
          >
            MEDICAL PERSISTENCE
          </Box>
          <Box style={{ fontSize: '16px', opacity: 0.8 }}>
            HEALTHCARE & TREATMENT
          </Box>
        </Box>

        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
          <Box style={{ textAlign: 'center', marginBottom: '15px' }}>
            MEDICAL PERSISTENCE SYSTEM
          </Box>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
        </Box>

        {/* Medical Controls */}
        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            MEDICAL CONTROLS:
          </Box>
          <Flex wrap="wrap" style={{ gap: '10px', marginBottom: '20px' }}>
            <ActionButton
              action="medical_view_status"
              icon="📊"
              color="blue"
              successMessage="Medical status retrieved"
              tooltip="View medical status"
            >
              VIEW STATUS
            </ActionButton>
            <EnhancedButton
              icon="👤"
              color="purple"
              onClick={() => setMedicalModalOpen(true)}
              tooltip="Open detailed patient registration form"
            >
              ADD PATIENT
            </EnhancedButton>
            <ActionButton
              action="medical_add_treatment"
              icon="💊"
              color="default"
              successMessage="Treatment added successfully"
              errorMessage="Failed to add treatment"
              tooltip="Add new treatment"
            >
              ADD TREATMENT
            </ActionButton>
            <ActionButton
              action="medical_save_data"
              icon="💾"
              color="good"
              successMessage="Medical data saved successfully"
              errorMessage="Failed to save medical data"
              tooltip="Save medical data"
            >
              SAVE DATA
            </ActionButton>
            <ActionButton
              action="medical_add_record"
              icon="📋"
              color="average"
              successMessage="Medical record added successfully"
              errorMessage="Failed to add medical record"
              tooltip="Add medical record"
            >
              ADD RECORD
            </ActionButton>
            <ActionButton
              action="medical_add_outbreak"
              icon="🦠"
              color="bad"
              successMessage="Outbreak reported successfully"
              errorMessage="Failed to report outbreak"
              tooltip="Report disease outbreak"
            >
              REPORT OUTBREAK
            </ActionButton>
            <ActionButton
              action="medical_add_research"
              icon="🔬"
              color="blue"
              successMessage="Research project added successfully"
              errorMessage="Failed to add research project"
              tooltip="Add research project"
            >
              ADD RESEARCH
            </ActionButton>
            <ActionButton
              action="medical_load_data"
              icon="📂"
              color="default"
              successMessage="Medical data loaded successfully"
              errorMessage="Failed to load medical data"
              tooltip="Load medical data"
            >
              LOAD DATA
            </ActionButton>
            <EnhancedButton
              icon="📤"
              color="average"
              onClick={() => {
                addNotification('Export', 'Exporting patient data...', 'info');
                setTimeout(
                  () =>
                    addNotification(
                      'Export',
                      'Patient data exported successfully',
                      'success',
                    ),
                  1500,
                );
              }}
              tooltip="Export patient data"
            >
              EXPORT
            </EnhancedButton>
            <EnhancedButton
              icon="📥"
              color="average"
              onClick={() => {
                addNotification('Import', 'Importing patient data...', 'info');
                setTimeout(
                  () =>
                    addNotification(
                      'Import',
                      'Patient data imported successfully',
                      'success',
                    ),
                  1500,
                );
              }}
              tooltip="Import patient data"
            >
              IMPORT
            </EnhancedButton>
            <EnhancedButton
              icon="⚡"
              color="purple"
              onClick={() => {
                addNotification(
                  'Bulk Actions',
                  'Processing bulk operations...',
                  'info',
                );
                setTimeout(
                  () =>
                    addNotification(
                      'Bulk Actions',
                      'Bulk operations completed',
                      'success',
                    ),
                  2000,
                );
              }}
              tooltip="Bulk operations"
            >
              BULK ACTIONS
            </EnhancedButton>
          </Flex>
        </Box>

        {/* Medical Status */}
        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            MEDICAL STATUS:
          </Box>
          <Grid style={{ gap: '10px' }}>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {medical_data?.total_patients || 0}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  TOTAL PATIENTS
                </Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {medical_data?.active_treatments || 0}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  ACTIVE TREATMENTS
                </Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {medical_data?.health_rating || 0}%
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  HEALTH RATING
                </Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {medical_data?.outbreaks || 0}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  ACTIVE OUTBREAKS
                </Box>
              </Box>
            </Grid.Column>
          </Grid>
        </Box>

        {/* Medical Navigation Tabs */}
        <Flex
          style={{
            marginBottom: '20px',
            borderBottom: '1px solid rgba(255,255,255,0.3)',
          }}
        >
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                effectiveActiveTab === 'overview'
                  ? '2px solid #66ff66'
                  : 'none',
              color: effectiveActiveTab === 'overview' ? '#66ff66' : '#ffffff',
            }}
            onClick={() => {
              console.log('MedicalInterface: Clicking overview tab');
              setMedicalActiveTab('overview');
            }}
          >
            OVERVIEW
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                effectiveActiveTab === 'patients'
                  ? '2px solid #66ff66'
                  : 'none',
              color: effectiveActiveTab === 'patients' ? '#66ff66' : '#ffffff',
            }}
            onClick={() => {
              console.log('MedicalInterface: Clicking patients tab');
              setMedicalActiveTab('patients');
            }}
          >
            PATIENTS
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                effectiveActiveTab === 'treatments'
                  ? '2px solid #66ff66'
                  : 'none',
              color:
                effectiveActiveTab === 'treatments' ? '#66ff66' : '#ffffff',
            }}
            onClick={() => {
              console.log('MedicalInterface: Clicking treatments tab');
              setMedicalActiveTab('treatments');
            }}
          >
            TREATMENTS
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                effectiveActiveTab === 'outbreaks'
                  ? '2px solid #66ff66'
                  : 'none',
              color: effectiveActiveTab === 'outbreaks' ? '#66ff66' : '#ffffff',
            }}
            onClick={() => {
              console.log('MedicalInterface: Clicking outbreaks tab');
              setMedicalActiveTab('outbreaks');
            }}
          >
            OUTBREAKS
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom:
                effectiveActiveTab === 'research'
                  ? '2px solid #66ff66'
                  : 'none',
              color: effectiveActiveTab === 'research' ? '#66ff66' : '#ffffff',
            }}
            onClick={() => {
              console.log('MedicalInterface: Clicking research tab');
              setMedicalActiveTab('research');
            }}
          >
            RESEARCH
          </Box>
        </Flex>

        {/* Overview Tab */}
        {effectiveActiveTab === 'overview' && (
          <Box>
            {/* Debug: Overview tab content is rendering */}
            <Box
              style={{
                color: 'yellow',
                fontSize: '12px',
                marginBottom: '10px',
              }}
            >
              MedicalInterface: Overview tab content is rendering
            </Box>
            <Box
              style={{
                fontSize: '12px',
                opacity: 0.7,
                textAlign: 'center',
                marginTop: '20px',
              }}
            >
              Medical system overview - all systems operational.
            </Box>

            <Section title="Quick Actions">
              <Flex wrap="wrap" style={{ gap: '10px' }}>
                <Button
                  onClick={() => act('medical_add_record')}
                  icon="user-plus"
                  color="good"
                >
                  Add Patient
                </Button>
                <Button
                  onClick={() => act('medical_add_treatment')}
                  icon="stethoscope"
                  color="blue"
                >
                  Add Treatment
                </Button>
                <Button
                  onClick={() => act('medical_add_outbreak')}
                  icon="virus"
                  color="bad"
                >
                  Report Outbreak
                </Button>
                <Button
                  onClick={() => act('medical_add_research')}
                  icon="flask"
                  color="purple"
                >
                  New Research
                </Button>
                <Button
                  onClick={() => act('medical_save_data')}
                  icon="save"
                  color="default"
                >
                  Save Data
                </Button>
                <Button
                  onClick={() => act('medical_load_data')}
                  icon="download"
                  color="default"
                >
                  Load Data
                </Button>
              </Flex>
            </Section>
          </Box>
        )}

        {/* Patients Tab */}
        {effectiveActiveTab === 'patients' && (
          <Box>
            {/* Debug: Check patient data */}
            <Box
              style={{
                color: 'yellow',
                fontSize: '12px',
                marginBottom: '10px',
              }}
            >
              Debug: patient_records count ={' '}
              {medical_data?.patient_records?.length || 0}
            </Box>
            <Section title="Patient Records">
              {/* Search and Filter Controls */}
              <Box style={{ marginBottom: '15px' }}>
                <Flex style={{ gap: '10px', marginBottom: '10px' }}>
                  <Box style={{ flex: 1 }}>
                    <input
                      type="text"
                      placeholder="Search patients..."
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      style={{
                        width: '100%',
                        padding: '8px',
                        background: 'rgba(0,0,0,0.5)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        color: '#ffffff',
                        fontFamily: 'monospace',
                        fontSize: '12px',
                      }}
                    />
                  </Box>
                  <Box>
                    <select
                      value={filterType}
                      onChange={(e) => setFilterType(e.target.value)}
                      style={{
                        padding: '8px',
                        background: 'rgba(0,0,0,0.5)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        color: '#ffffff',
                        fontFamily: 'monospace',
                        fontSize: '12px',
                      }}
                    >
                      <option value="all">All Patients</option>
                      <option value="active">Active</option>
                      <option value="critical">Critical</option>
                      <option value="recovered">Recovered</option>
                    </select>
                  </Box>
                  <Box>
                    <select
                      value={sortBy}
                      onChange={(e) => setSortBy(e.target.value)}
                      style={{
                        padding: '8px',
                        background: 'rgba(0,0,0,0.5)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        color: '#ffffff',
                        fontFamily: 'monospace',
                        fontSize: '12px',
                      }}
                    >
                      <option value="name">Name</option>
                      <option value="health">Health Rating</option>
                      <option value="date">Last Updated</option>
                    </select>
                  </Box>
                  <Button
                    onClick={() =>
                      setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc')
                    }
                    icon={sortOrder === 'asc' ? 'sort-up' : 'sort-down'}
                    size="small"
                  >
                    {sortOrder.toUpperCase()}
                  </Button>
                </Flex>
                <Flex style={{ gap: '10px' }}>
                  <Button
                    onClick={() => act('medical_export_patients')}
                    icon="download"
                    size="small"
                    color="blue"
                  >
                    Export Data
                  </Button>
                  <Button
                    onClick={() => act('medical_import_patients')}
                    icon="upload"
                    size="small"
                    color="green"
                  >
                    Import Data
                  </Button>
                  <Button
                    onClick={() => act('medical_bulk_actions')}
                    icon="tasks"
                    size="small"
                    color="purple"
                  >
                    Bulk Actions
                  </Button>
                </Flex>
              </Box>

              <Box className="scrollable-table">
                <Table>
                  <Table.Row header>
                    <Table.Cell>
                      <input type="checkbox" style={{ marginRight: '5px' }} />
                    </Table.Cell>
                    <Table.Cell>Name</Table.Cell>
                    <Table.Cell>Blood Type</Table.Cell>
                    <Table.Cell>Health Rating</Table.Cell>
                    <Table.Cell>Status</Table.Cell>
                    <Table.Cell>Last Updated</Table.Cell>
                    <Table.Cell>Actions</Table.Cell>
                  </Table.Row>
                  {/* Real patient data from backend */}
                  {medical_data?.patient_records &&
                  medical_data.patient_records.length > 0 ? (
                    medical_data.patient_records.map((patient, index) => (
                      <Table.Row key={index}>
                        <Table.Cell>
                          <input type="checkbox" />
                        </Table.Cell>
                        <Table.Cell>{patient.name}</Table.Cell>
                        <Table.Cell>{patient.blood_type}</Table.Cell>
                        <Table.Cell>
                          <ProgressBar
                            value={patient.health_rating}
                            maxValue={100}
                            color={
                              patient.health_rating >= 80
                                ? 'good'
                                : patient.health_rating >= 60
                                  ? 'average'
                                  : 'bad'
                            }
                          />
                        </Table.Cell>
                        <Table.Cell>
                          <Box
                            style={{
                              color:
                                patient.health_rating >= 80
                                  ? '#66ff66'
                                  : patient.health_rating >= 60
                                    ? '#ffaa00'
                                    : '#ff6666',
                              fontWeight: 'bold',
                            }}
                          >
                            {patient.health_rating >= 80
                              ? 'ACTIVE'
                              : patient.health_rating >= 60
                                ? 'MONITORING'
                                : 'CRITICAL'}
                          </Box>
                        </Table.Cell>
                        <Table.Cell>{patient.last_updated}</Table.Cell>
                        <Table.Cell>
                          <Flex style={{ gap: '5px' }}>
                            <Button
                              size="small"
                              onClick={() => setSelectedPatient(patient.name)}
                            >
                              View
                            </Button>
                            <Button
                              size="small"
                              color="blue"
                              onClick={() =>
                                act('medical_edit_patient', {
                                  patient: patient.name,
                                })
                              }
                            >
                              Edit
                            </Button>
                          </Flex>
                        </Table.Cell>
                      </Table.Row>
                    ))
                  ) : (
                    <Table.Row>
                      <Table.Cell
                        colSpan={7}
                        style={{ textAlign: 'center', padding: '20px' }}
                      >
                        No patient records found. Add some patients to get
                        started.
                      </Table.Cell>
                    </Table.Row>
                  )}
                </Table>
              </Box>
            </Section>
          </Box>
        )}

        {/* Treatments Tab */}
        {effectiveActiveTab === 'treatments' && (
          <Box>
            <Section title="Treatment Logs">
              <Table>
                <Table.Row header>
                  <Table.Cell>Patient</Table.Cell>
                  <Table.Cell>Treatment Type</Table.Cell>
                  <Table.Cell>Doctor</Table.Cell>
                  <Table.Cell>Success</Table.Cell>
                  <Table.Cell>Date</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                {/* Real treatment data from backend */}
                {medical_data?.treatment_logs &&
                medical_data.treatment_logs.length > 0 ? (
                  medical_data.treatment_logs.map((treatment, index) => (
                    <Table.Row key={index}>
                      <Table.Cell>{treatment.patient}</Table.Cell>
                      <Table.Cell>{treatment.treatment_type}</Table.Cell>
                      <Table.Cell>{treatment.doctor}</Table.Cell>
                      <Table.Cell>
                        <Icon
                          name={treatment.success ? 'check' : 'times'}
                          color={treatment.success ? 'good' : 'bad'}
                        />
                      </Table.Cell>
                      <Table.Cell>{treatment.timestamp}</Table.Cell>
                      <Table.Cell>
                        <Button
                          size="small"
                          onClick={() =>
                            setSelectedTreatment(treatment.patient)
                          }
                        >
                          Details
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  ))
                ) : (
                  <Table.Row>
                    <Table.Cell
                      colSpan={6}
                      style={{ textAlign: 'center', padding: '20px' }}
                    >
                      No treatment logs found. Add some treatments to get
                      started.
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Section>
          </Box>
        )}

        {/* Outbreaks Tab */}
        {effectiveActiveTab === 'outbreaks' && (
          <Box>
            <Section title="Disease Outbreaks">
              <Table>
                <Table.Row header>
                  <Table.Cell>Disease</Table.Cell>
                  <Table.Cell>Type</Table.Cell>
                  <Table.Cell>Severity</Table.Cell>
                  <Table.Cell>Affected</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                {/* Real outbreak data from backend */}
                {medical_data?.outbreak_records &&
                medical_data.outbreak_records.length > 0 ? (
                  medical_data.outbreak_records.map((outbreak, index) => (
                    <Table.Row key={index}>
                      <Table.Cell>{outbreak.disease_name}</Table.Cell>
                      <Table.Cell>{outbreak.disease_type}</Table.Cell>
                      <Table.Cell>
                        <ProgressBar
                          value={outbreak.severity}
                          maxValue={5}
                          color={
                            outbreak.severity >= 4
                              ? 'bad'
                              : outbreak.severity >= 2
                                ? 'average'
                                : 'good'
                          }
                        />
                      </Table.Cell>
                      <Table.Cell>{outbreak.affected_count || 0}</Table.Cell>
                      <Table.Cell>
                        <Box
                          style={{
                            color:
                              outbreak.status === 'ACTIVE'
                                ? '#ff6666'
                                : '#66ff66',
                            fontWeight: 'bold',
                          }}
                        >
                          {outbreak.status}
                        </Box>
                      </Table.Cell>
                      <Table.Cell>
                        <Button
                          size="small"
                          onClick={() =>
                            setSelectedOutbreak(outbreak.disease_name)
                          }
                        >
                          Manage
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  ))
                ) : (
                  <Table.Row>
                    <Table.Cell
                      colSpan={6}
                      style={{ textAlign: 'center', padding: '20px' }}
                    >
                      No outbreak records found. Add some outbreaks to get
                      started.
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Section>
          </Box>
        )}

        {/* Research Tab */}
        {effectiveActiveTab === 'research' && (
          <Box>
            {/* Debug: Check research data */}
            <Box
              style={{
                color: 'yellow',
                fontSize: '12px',
                marginBottom: '10px',
              }}
            >
              Debug: research_projects count ={' '}
              {medical_data?.research_projects?.length || 0}
            </Box>
            <Section title="Medical Research Projects">
              <Table>
                <Table.Row header>
                  <Table.Cell>Project Name</Table.Cell>
                  <Table.Cell>Field</Table.Cell>
                  <Table.Cell>Lead Researcher</Table.Cell>
                  <Table.Cell>Progress</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                {/* Real research data from backend */}
                {medical_data?.research_projects &&
                medical_data.research_projects.length > 0 ? (
                  medical_data.research_projects.map((project, index) => (
                    <Table.Row key={index}>
                      <Table.Cell>{project.project_name}</Table.Cell>
                      <Table.Cell>{project.research_field}</Table.Cell>
                      <Table.Cell>{project.lead_researcher}</Table.Cell>
                      <Table.Cell>
                        <ProgressBar
                          value={project.progress || 0}
                          maxValue={100}
                          color="blue"
                        />
                      </Table.Cell>
                      <Table.Cell>
                        <Box style={{ color: '#66ff66', fontWeight: 'bold' }}>
                          {project.status || 'ACTIVE'}
                        </Box>
                      </Table.Cell>
                      <Table.Cell>
                        <Button
                          size="small"
                          onClick={() => {
                            console.log(
                              'Setting selectedProject to:',
                              project.project_name,
                            );
                            setSelectedProject(project.project_name);
                          }}
                        >
                          Details
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  ))
                ) : (
                  <Table.Row>
                    <Table.Cell
                      colSpan={6}
                      style={{ textAlign: 'center', padding: '20px' }}
                    >
                      No research projects found. Add some projects to get
                      started.
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Section>
          </Box>
        )}

        {/* Detail Modals */}
        {selectedPatient && selectedPatient !== 'medical' && (
          <Modal>
            <Section title={`Patient Details: ${selectedPatient}`}>
              <Box>
                {medical_data?.patient_records?.find(
                  (patient) => patient.name === selectedPatient,
                ) ? (
                  <Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Name:</strong> {selectedPatient}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Blood Type:</strong>{' '}
                      {medical_data.patient_records.find(
                        (patient) => patient.name === selectedPatient,
                      )?.blood_type || 'Unknown'}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Health Rating:</strong>{' '}
                      {medical_data.patient_records.find(
                        (patient) => patient.name === selectedPatient,
                      )?.health_rating || 0}
                      /100
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Current Conditions:</strong>{' '}
                      {medical_data.patient_records
                        .find((patient) => patient.name === selectedPatient)
                        ?.conditions?.join(', ') || 'None'}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Last Updated:</strong>{' '}
                      {medical_data.patient_records.find(
                        (patient) => patient.name === selectedPatient,
                      )?.last_updated || 'Unknown'}
                    </Box>
                  </Box>
                ) : (
                  <Box>Patient information not available.</Box>
                )}
              </Box>
              <Button onClick={() => setSelectedPatient(null)}>Close</Button>
            </Section>
          </Modal>
        )}

        {selectedTreatment && selectedTreatment !== 'medical' && (
          <Modal>
            <Section title={`Treatment Details: ${selectedTreatment}`}>
              <Box>
                {medical_data?.treatment_logs?.find(
                  (treatment) => treatment.patient === selectedTreatment,
                ) ? (
                  <Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Patient:</strong> {selectedTreatment}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Treatment Type:</strong>{' '}
                      {medical_data.treatment_logs.find(
                        (treatment) => treatment.patient === selectedTreatment,
                      )?.treatment_type || 'Unknown'}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Doctor:</strong>{' '}
                      {medical_data.treatment_logs.find(
                        (treatment) => treatment.patient === selectedTreatment,
                      )?.doctor || 'Unknown'}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Success:</strong>{' '}
                      {medical_data.treatment_logs.find(
                        (treatment) => treatment.patient === selectedTreatment,
                      )?.success
                        ? 'Yes'
                        : 'No'}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Notes:</strong>{' '}
                      {medical_data.treatment_logs.find(
                        (treatment) => treatment.patient === selectedTreatment,
                      )?.notes || 'No notes available'}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Timestamp:</strong>{' '}
                      {medical_data.treatment_logs.find(
                        (treatment) => treatment.patient === selectedTreatment,
                      )?.timestamp || 'Unknown'}
                    </Box>
                  </Box>
                ) : (
                  <Box>Treatment information not available.</Box>
                )}
              </Box>
              <Button onClick={() => setSelectedTreatment(null)}>Close</Button>
            </Section>
          </Modal>
        )}

        {shouldShowOutbreakModal && (
          <Modal>
            <Section title={`Outbreak Management: ${selectedOutbreak}`}>
              {/* Debug info */}
              <Box
                style={{
                  color: 'yellow',
                  fontSize: '12px',
                  marginBottom: '10px',
                }}
              >
                Debug: selectedOutbreak = &quot;{selectedOutbreak}&quot;
              </Box>
              <Box>
                {medical_data?.outbreak_records?.find(
                  (outbreak) => outbreak.disease_name === selectedOutbreak,
                ) ? (
                  <Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Disease:</strong> {selectedOutbreak}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Type:</strong>{' '}
                      {medical_data.outbreak_records.find(
                        (outbreak) =>
                          outbreak.disease_name === selectedOutbreak,
                      )?.disease_type || 'Unknown'}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Severity:</strong>{' '}
                      {medical_data.outbreak_records.find(
                        (outbreak) =>
                          outbreak.disease_name === selectedOutbreak,
                      )?.severity || 0}
                      /5
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Status:</strong>{' '}
                      {medical_data.outbreak_records.find(
                        (outbreak) =>
                          outbreak.disease_name === selectedOutbreak,
                      )?.status || 'Unknown'}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Start Time:</strong>{' '}
                      {medical_data.outbreak_records.find(
                        (outbreak) =>
                          outbreak.disease_name === selectedOutbreak,
                      )?.start_time || 'Unknown'}
                    </Box>
                  </Box>
                ) : (
                  <Box>Outbreak information not available.</Box>
                )}
              </Box>
              <Button onClick={() => setSelectedOutbreak(null)}>Close</Button>
            </Section>
          </Modal>
        )}

        {selectedProject && selectedProject !== 'medical' && (
          <Modal>
            <Section title={`Research Project: ${selectedProject}`}>
              <Box>
                {/* Debug info */}
                <Box
                  style={{
                    color: 'yellow',
                    fontSize: '12px',
                    marginBottom: '10px',
                  }}
                >
                  Debug: selectedProject = &quot;{selectedProject}&quot;
                </Box>
                <Box
                  style={{
                    color: 'yellow',
                    fontSize: '12px',
                    marginBottom: '10px',
                  }}
                >
                  Debug: research_projects count ={' '}
                  {medical_data?.research_projects?.length || 0}
                </Box>
                {medical_data?.research_projects?.map((project, index) => (
                  <Box
                    key={index}
                    style={{ color: 'yellow', fontSize: '12px' }}
                  >
                    Debug: project[{index}] = &quot;{project.project_name}&quot;
                  </Box>
                ))}
                {medical_data?.research_projects?.find(
                  (project) => project.project_name === selectedProject,
                ) ? (
                  <Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Project:</strong> {selectedProject}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Description:</strong>{' '}
                      {medical_data.research_projects.find(
                        (project) => project.project_name === selectedProject,
                      )?.project_description || 'No description available'}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Field:</strong>{' '}
                      {medical_data.research_projects.find(
                        (project) => project.project_name === selectedProject,
                      )?.research_field || 'Unknown'}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Lead Researcher:</strong>{' '}
                      {medical_data.research_projects.find(
                        (project) => project.project_name === selectedProject,
                      )?.lead_researcher || 'Unknown'}
                    </Box>
                    <Box style={{ marginBottom: '10px' }}>
                      <strong>Status:</strong>{' '}
                      {medical_data.research_projects.find(
                        (project) => project.project_name === selectedProject,
                      )?.status || 'Unknown'}
                    </Box>
                  </Box>
                ) : (
                  <Box>Research project information not available.</Box>
                )}
              </Box>
              <Button onClick={() => setSelectedProject(null)}>Close</Button>
            </Section>
          </Modal>
        )}

        <Box
          style={{
            fontSize: '12px',
            opacity: 0.7,
            textAlign: 'center',
            marginTop: '20px',
          }}
        >
          Medical persistence system managing patient records, treatments,
          outbreaks, and healthcare operations.
        </Box>
      </Box>
    );
  };

  // Security Management Interface
  const SecurityInterface = ({ securityActiveTab, setSecurityActiveTab }) => {
    const [selectedIncident, setSelectedIncident] = useLocalState(
      context,
      'selectedIncident',
      null,
    );
    const [selectedPersonnel, setSelectedPersonnel] = useLocalState(
      context,
      'selectedPersonnel',
      null,
    );
    const [selectedProtocol, setSelectedProtocol] = useLocalState(
      context,
      'selectedProtocol',
      null,
    );
    const [selectedAccess, setSelectedAccess] = useLocalState(
      context,
      'selectedAccess',
      null,
    );

    return (
      <Box
        style={{
          background: 'rgba(0,0,0,0.7)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: '5px',
          padding: '20px',
          fontFamily: 'monospace',
          fontSize: '14px',
          color: '#ffffff',
          minHeight: '100%',
          position: 'relative',
        }}
      >
        {/* Back to Desktop Button */}
        <Box
          style={{
            position: 'absolute',
            top: '10px',
            right: '10px',
            padding: '8px 16px',
            background: 'rgba(255,255,255,0.1)',
            border: '1px solid rgba(255,255,255,0.3)',
            borderRadius: '5px',
            cursor: 'pointer',
            fontSize: '12px',
            transition: 'all 0.3s ease',
          }}
          onClick={() => setActiveTab('desktop')}
          onMouseEnter={(e) => {
            e.target.style.background = 'rgba(255,255,255,0.2)';
          }}
          onMouseLeave={(e) => {
            e.target.style.background = 'rgba(255,255,255,0.1)';
          }}
        >
          ← BACK TO DESKTOP
        </Box>
        <Box style={{ marginBottom: '20px' }}>
          <Box
            style={{
              fontSize: '24px',
              fontWeight: 'bold',
              marginBottom: '5px',
            }}
          >
            SECURITY PERSISTENCE
          </Box>
          <Box style={{ fontSize: '16px', opacity: 0.8 }}>
            SURVEILLANCE & PROTECTION
          </Box>
        </Box>

        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
          <Box style={{ textAlign: 'center', marginBottom: '15px' }}>
            SECURITY PERSISTENCE SYSTEM
          </Box>
          <Box style={{ marginBottom: '15px' }}>
            {Array(50).fill('─').join('')}
          </Box>
        </Box>

        {/* Security Controls */}
        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            SECURITY CONTROLS:
          </Box>
          <Flex wrap="wrap" style={{ gap: '10px', marginBottom: '20px' }}>
            <ActionButton
              action="security_view_status"
              icon="📊"
              color="blue"
              successMessage="Security status retrieved"
              tooltip="View security status"
            >
              VIEW STATUS
            </ActionButton>
            <EnhancedButton
              icon="🚨"
              color="bad"
              onClick={() => setSecurityModalOpen(true)}
              tooltip="Open detailed security incident report form"
            >
              ADD INCIDENT
            </EnhancedButton>
            <EnhancedButton
              icon="👥"
              color="purple"
              onClick={() => setSecurityPersonnelModalOpen(true)}
              tooltip="Open detailed security personnel management form"
            >
              MANAGE PERSONNEL
            </EnhancedButton>
            <EnhancedButton
              icon="📋"
              color="default"
              onClick={() => setSecurityLogsModalOpen(true)}
              tooltip="Open detailed security logs viewer and management form"
            >
              VIEW LOGS
            </EnhancedButton>
            <ActionButton
              action="security_save_data"
              icon="💾"
              color="good"
              successMessage="Security data saved successfully"
              errorMessage="Failed to save security data"
              tooltip="Save security data"
            >
              SAVE DATA
            </ActionButton>
            <ActionButton
              action="security_load_data"
              icon="📂"
              color="default"
              successMessage="Security data loaded successfully"
              errorMessage="Failed to load security data"
              tooltip="Load security data"
            >
              LOAD DATA
            </ActionButton>
            <EnhancedButton
              icon="🔍"
              color="average"
              onClick={() => setSecurityScanModalOpen(true)}
              tooltip="Open detailed security scan configuration form"
            >
              SECURITY SCAN
            </EnhancedButton>
            <EnhancedButton
              icon="🚪"
              color="blue"
              onClick={() => setSecurityAccessModalOpen(true)}
              tooltip="Open detailed access control management form"
            >
              ACCESS CONTROL
            </EnhancedButton>
          </Flex>
        </Box>

        {/* Security Status */}
        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            SECURITY STATUS:
          </Box>
          <Grid style={{ gap: '10px' }}>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {security_data?.total_incidents || 0}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  TOTAL INCIDENTS
                </Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {security_data?.active_personnel || 0}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  ACTIVE PERSONNEL
                </Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {security_data?.security_level || 0}%
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  SECURITY LEVEL
                </Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,255,255,0.05)',
                  border: '1px solid rgba(255,255,255,0.2)',
                  borderRadius: '3px',
                  padding: '15px',
                  textAlign: 'center',
                }}
              >
                <Box style={{ fontSize: '18px', fontWeight: 'bold' }}>
                  {security_data?.protocols_active || 0}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  ACTIVE PROTOCOLS
                </Box>
              </Box>
            </Grid.Column>
          </Grid>
        </Box>

        {/* Security Navigation Tabs */}
        <Flex
          style={{
            marginBottom: '20px',
            borderBottom: '1px solid rgba(255,255,255,0.3)',
            gap: '5px',
          }}
        >
          <NavButton
            isActive={securityActiveTab === 'overview'}
            onClick={() => setSecurityActiveTab('overview')}
            icon="📊"
          >
            OVERVIEW
          </NavButton>
          <NavButton
            isActive={securityActiveTab === 'incidents'}
            onClick={() => setSecurityActiveTab('incidents')}
            icon="🚨"
          >
            INCIDENTS
          </NavButton>
          <NavButton
            isActive={securityActiveTab === 'personnel'}
            onClick={() => setSecurityActiveTab('personnel')}
            icon="👥"
          >
            PERSONNEL
          </NavButton>
          <NavButton
            isActive={securityActiveTab === 'protocols'}
            onClick={() => setSecurityActiveTab('protocols')}
            icon="📋"
          >
            PROTOCOLS
          </NavButton>
          <NavButton
            isActive={securityActiveTab === 'access'}
            onClick={() => setSecurityActiveTab('access')}
            icon="🚪"
          >
            ACCESS LOGS
          </NavButton>
        </Flex>

        {/* Overview Tab */}
        {securityActiveTab === 'overview' && (
          <Box>
            <Box
              style={{
                fontSize: '12px',
                opacity: 0.7,
                textAlign: 'center',
                marginTop: '20px',
              }}
            >
              Security system overview - all systems operational.
            </Box>

            <Section title="Quick Actions">
              <Flex wrap="wrap" style={{ gap: '10px' }}>
                <Button
                  onClick={() => act('security_add_incident')}
                  icon="exclamation-triangle"
                  color="bad"
                >
                  Report Incident
                </Button>
                <Button
                  onClick={() => act('security_add_personnel')}
                  icon="user-shield"
                  color="blue"
                >
                  Add Personnel
                </Button>
                <Button
                  onClick={() => act('security_add_protocol')}
                  icon="shield-alt"
                  color="purple"
                >
                  New Protocol
                </Button>
                <Button
                  onClick={() => act('security_add_clearance')}
                  icon="key"
                  color="orange"
                >
                  Clearance Request
                </Button>
                <Button
                  onClick={() => act('security_save_data')}
                  icon="save"
                  color="default"
                >
                  Save Data
                </Button>
                <Button
                  onClick={() => act('security_load_data')}
                  icon="download"
                  color="default"
                >
                  Load Data
                </Button>
              </Flex>
            </Section>
          </Box>
        )}

        {/* Incidents Tab */}
        {securityActiveTab === 'incidents' && (
          <Box>
            <Section title="Security Incidents">
              <Box className="scrollable-table">
                <Table>
                  <Table.Row header>
                    <Table.Cell>Type</Table.Cell>
                    <Table.Cell>Description</Table.Cell>
                    <Table.Cell>Severity</Table.Cell>
                    <Table.Cell>Location</Table.Cell>
                    <Table.Cell>Status</Table.Cell>
                    <Table.Cell>Actions</Table.Cell>
                  </Table.Row>
                  {/* Real incident data from backend */}
                  {security_data?.security_incidents &&
                  security_data.security_incidents.length > 0 ? (
                    security_data.security_incidents.map((incident, index) => (
                      <Table.Row key={index}>
                        <Table.Cell>{incident.type}</Table.Cell>
                        <Table.Cell>{incident.description}</Table.Cell>
                        <Table.Cell>
                          <ProgressBar
                            value={incident.severity}
                            maxValue={5}
                            color={
                              incident.severity >= 4
                                ? 'bad'
                                : incident.severity >= 2
                                  ? 'average'
                                  : 'good'
                            }
                          />
                        </Table.Cell>
                        <Table.Cell>{incident.location}</Table.Cell>
                        <Table.Cell>
                          <Box
                            style={{
                              color:
                                incident.status === 'ACTIVE'
                                  ? '#ff6666'
                                  : incident.status === 'RESOLVED'
                                    ? '#66ff66'
                                    : '#ffaa00',
                              fontWeight: 'bold',
                            }}
                          >
                            {incident.status}
                          </Box>
                        </Table.Cell>
                        <Table.Cell>
                          <Button
                            size="small"
                            onClick={() => setSelectedIncident(incident.type)}
                          >
                            {incident.status === 'ACTIVE' ? 'Manage' : 'View'}
                          </Button>
                        </Table.Cell>
                      </Table.Row>
                    ))
                  ) : (
                    <Table.Row>
                      <Table.Cell
                        colSpan={6}
                        style={{ textAlign: 'center', padding: '20px' }}
                      >
                        No security incidents recorded. All systems secure.
                      </Table.Cell>
                    </Table.Row>
                  )}
                </Table>
              </Box>
            </Section>
          </Box>
        )}

        {/* Personnel Tab */}
        {securityActiveTab === 'personnel' && (
          <Box>
            <Section title="Security Personnel">
              <Table>
                <Table.Row header>
                  <Table.Cell>Name</Table.Cell>
                  <Table.Cell>Clearance Level</Table.Cell>
                  <Table.Cell>Security Rating</Table.Cell>
                  <Table.Cell>Incidents</Table.Cell>
                  <Table.Cell>Last Updated</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                {/* Real security personnel data from backend */}
                {security_data?.security_personnel &&
                security_data.security_personnel.length > 0 ? (
                  security_data.security_personnel.map((personnel, index) => (
                    <Table.Row key={index}>
                      <Table.Cell>{personnel.name}</Table.Cell>
                      <Table.Cell>Level {personnel.clearance_level}</Table.Cell>
                      <Table.Cell>
                        <ProgressBar
                          value={personnel.security_rating}
                          maxValue={100}
                          color={
                            personnel.security_rating >= 80
                              ? 'good'
                              : personnel.security_rating >= 60
                                ? 'average'
                                : 'bad'
                          }
                        />
                      </Table.Cell>
                      <Table.Cell>{personnel.incidents_handled}</Table.Cell>
                      <Table.Cell>{personnel.last_updated}</Table.Cell>
                      <Table.Cell>
                        <Button
                          size="small"
                          onClick={() => setSelectedPersonnel(personnel.name)}
                        >
                          View
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  ))
                ) : (
                  <Table.Row>
                    <Table.Cell
                      colSpan={6}
                      style={{ textAlign: 'center', padding: '20px' }}
                    >
                      No security personnel records found.
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Section>
          </Box>
        )}

        {/* Protocols Tab */}
        {securityActiveTab === 'protocols' && (
          <Box>
            <Section title="Security Protocols">
              <Table>
                <Table.Row header>
                  <Table.Cell>Protocol Name</Table.Cell>
                  <Table.Cell>Clearance Required</Table.Cell>
                  <Table.Cell>Effectiveness</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                {/* Real security incidents data from backend */}
                {security_data?.security_incidents &&
                security_data.security_incidents.length > 0 ? (
                  security_data.security_incidents.map((incident, index) => (
                    <Table.Row key={index}>
                      <Table.Cell>{incident.type}</Table.Cell>
                      <Table.Cell>Level {incident.severity}</Table.Cell>
                      <Table.Cell>
                        <ProgressBar
                          value={incident.severity}
                          maxValue={5}
                          color={
                            incident.severity >= 4
                              ? 'bad'
                              : incident.severity >= 2
                                ? 'average'
                                : 'good'
                          }
                        />
                      </Table.Cell>
                      <Table.Cell>
                        <Box
                          style={{
                            color:
                              incident.status === 'RESOLVED'
                                ? '#66ff66'
                                : '#ff6666',
                            fontWeight: 'bold',
                          }}
                        >
                          {incident.status}
                        </Box>
                      </Table.Cell>
                      <Table.Cell>
                        <Button
                          size="small"
                          onClick={() => setSelectedProtocol(incident.type)}
                        >
                          Edit
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  ))
                ) : (
                  <Table.Row>
                    <Table.Cell
                      colSpan={5}
                      style={{ textAlign: 'center', padding: '20px' }}
                    >
                      No security incidents found.
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Section>
          </Box>
        )}

        {/* Access Logs Tab */}
        {securityActiveTab === 'access' && (
          <Box>
            <Section title="Access Logs">
              <Table>
                <Table.Row header>
                  <Table.Cell>Personnel</Table.Cell>
                  <Table.Cell>Access Point</Table.Cell>
                  <Table.Cell>Clearance</Table.Cell>
                  <Table.Cell>Granted</Table.Cell>
                  <Table.Cell>Time</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                {/* Real access logs data from backend */}
                {security_data?.access_logs &&
                security_data.access_logs.length > 0 ? (
                  security_data.access_logs.map((log, index) => (
                    <Table.Row key={index}>
                      <Table.Cell>{log.user}</Table.Cell>
                      <Table.Cell>{log.location}</Table.Cell>
                      <Table.Cell>Level {log.access_type}</Table.Cell>
                      <Table.Cell>
                        <Icon
                          name={log.success ? 'check' : 'times'}
                          color={log.success ? 'good' : 'bad'}
                        />
                      </Table.Cell>
                      <Table.Cell>{log.timestamp}</Table.Cell>
                      <Table.Cell>
                        <Button
                          size="small"
                          onClick={() => setSelectedAccess(log.user)}
                        >
                          Details
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  ))
                ) : (
                  <Table.Row>
                    <Table.Cell
                      colSpan={6}
                      style={{ textAlign: 'center', padding: '20px' }}
                    >
                      No access logs found.
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Section>
          </Box>
        )}

        {/* Detail Modals */}
        {selectedIncident && (
          <Modal>
            <Section title={`Incident Details: ${selectedIncident}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Type:</strong> {selectedIncident}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Description:</strong> No description available
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Severity:</strong> 0/5
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Location:</strong> Unknown
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> Resolved
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Timestamp:</strong> Never
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  Incident details will be populated from security data.
                </Box>
              </Box>
              <Button onClick={() => setSelectedIncident(null)}>Close</Button>
            </Section>
          </Modal>
        )}

        {selectedPersonnel && (
          <Modal>
            <Section title={`Personnel Details: ${selectedPersonnel}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Name:</strong> {selectedPersonnel}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Clearance Level:</strong> Level 1
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Security Rating:</strong> 100/100
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Incidents Handled:</strong> 0
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Last Updated:</strong> Never
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  Personnel details will be populated from security data.
                </Box>
              </Box>
              <Button onClick={() => setSelectedPersonnel(null)}>Close</Button>
            </Section>
          </Modal>
        )}

        {selectedProtocol && (
          <Modal>
            <Section title={`Protocol Details: ${selectedProtocol}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Protocol:</strong> {selectedProtocol}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> Active
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Clearance Required:</strong> Level 3
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Description:</strong> Standard security protocol for
                  containment and response procedures.
                </Box>
              </Box>
              <Button onClick={() => setSelectedProtocol(null)}>Close</Button>
            </Section>
          </Modal>
        )}

        {selectedAccess && (
          <Modal>
            <Section title={`Access Details: ${selectedAccess}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>User:</strong> {selectedAccess}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> No Access Logs
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Last Activity:</strong> Never
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  Access logs will appear here when users interact with security
                  systems.
                </Box>
              </Box>
              <Button
                onClick={() => {
                  console.log(
                    'Closing access modal, setting selectedAccess to null',
                  );
                  setSelectedAccess(null);
                }}
              >
                Close
              </Button>
            </Section>
          </Modal>
        )}
      </Box>
    );
  };

  // Research Management Interface
  const ResearchInterface = ({ researchActiveTab, setResearchActiveTab }) => {
    const [selectedProject, setSelectedProject] = useLocalState(
      context,
      'researchSelectedProject',
      null,
    );
    const [selectedDiscovery, setSelectedDiscovery] = useLocalState(
      context,
      'researchSelectedDiscovery',
      null,
    );
    const [selectedPublication, setSelectedPublication] = useLocalState(
      context,
      'researchSelectedPublication',
      null,
    );
    const [selectedFacility, setSelectedFacility] = useLocalState(
      context,
      'researchSelectedFacility',
      null,
    );

    return (
      <Box
        style={{
          background: 'rgba(0,0,0,0.7)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: '5px',
          padding: '20px',
          fontFamily: 'monospace',
          fontSize: '14px',
          color: '#ffffff',
          minHeight: '100%',
          position: 'relative',
        }}
      >
        {/* Back to Desktop Button */}
        <Box
          style={{
            position: 'absolute',
            top: '10px',
            right: '10px',
            padding: '8px 16px',
            background: 'rgba(255,255,255,0.1)',
            border: '1px solid rgba(255,255,255,0.3)',
            borderRadius: '5px',
            cursor: 'pointer',
            fontSize: '12px',
            transition: 'all 0.3s ease',
          }}
          onClick={() => setActiveTab('desktop')}
          onMouseEnter={(e) => {
            e.target.style.background = 'rgba(255,255,255,0.2)';
          }}
          onMouseLeave={(e) => {
            e.target.style.background = 'rgba(255,255,255,0.1)';
          }}
        >
          ← BACK TO DESKTOP
        </Box>
        <Box style={{ marginBottom: '20px' }}>
          <Box
            style={{
              fontSize: '24px',
              fontWeight: 'bold',
              marginBottom: '5px',
            }}
          >
            RESEARCH PERSISTENCE
          </Box>
          <Box style={{ fontSize: '16px', opacity: 0.8 }}>
            STUDIES & EXPERIMENTS
          </Box>
        </Box>

        {/* Research Navigation Tabs */}
        <Flex
          style={{
            marginBottom: '20px',
            borderBottom: '1px solid rgba(255,255,255,0.3)',
            gap: '5px',
          }}
        >
          <NavButton
            isActive={researchActiveTab === 'overview'}
            onClick={() => setResearchActiveTab('overview')}
            icon="📊"
          >
            OVERVIEW
          </NavButton>
          <NavButton
            isActive={researchActiveTab === 'projects'}
            onClick={() => setResearchActiveTab('projects')}
            icon="📋"
          >
            PROJECTS
          </NavButton>
          <NavButton
            isActive={researchActiveTab === 'discoveries'}
            onClick={() => setResearchActiveTab('discoveries')}
            icon="🔬"
          >
            DISCOVERIES
          </NavButton>
          <NavButton
            isActive={researchActiveTab === 'publications'}
            onClick={() => setResearchActiveTab('publications')}
            icon="📄"
          >
            PUBLICATIONS
          </NavButton>
          <NavButton
            isActive={researchActiveTab === 'facilities'}
            onClick={() => setResearchActiveTab('facilities')}
            icon="🏢"
          >
            FACILITIES
          </NavButton>
        </Flex>

        {/* Overview Tab */}
        {researchActiveTab === 'overview' && (
          <Box>
            <Box
              style={{
                fontSize: '12px',
                opacity: 0.7,
                textAlign: 'center',
                marginTop: '20px',
              }}
            >
              Research system overview - all systems operational.
            </Box>

            <Section title="Quick Actions">
              <Box style={{ marginBottom: '15px' }}>
                <EnhancedButton
                  icon="📋"
                  color="good"
                  onClick={() => {
                    console.log(
                      'Opening research modal, current state:',
                      researchModalOpen,
                    );
                    setResearchModalOpen(true);
                    console.log('Research modal state set to true');
                  }}
                  tooltip="Open detailed research project creation form"
                >
                  📋 ADD NEW RESEARCH PROJECT
                </EnhancedButton>
              </Box>
              <Flex wrap="wrap" style={{ gap: '10px' }}>
                <ActionButton
                  action="research_add_project"
                  icon="📋"
                  color="blue"
                  successMessage="Research project added successfully"
                  errorMessage="Failed to add research project"
                  tooltip="Add new research project"
                >
                  New Project
                </ActionButton>
                <ActionButton
                  action="research_add_discovery"
                  icon="💡"
                  color="average"
                  successMessage="Discovery recorded successfully"
                  errorMessage="Failed to record discovery"
                  tooltip="Record new discovery"
                >
                  Record Discovery
                </ActionButton>
                <ActionButton
                  action="research_add_publication"
                  icon="📄"
                  color="purple"
                  successMessage="Paper published successfully"
                  errorMessage="Failed to publish paper"
                  tooltip="Publish research paper"
                >
                  Publish Paper
                </ActionButton>
                <ActionButton
                  action="research_add_facility"
                  icon="🏢"
                  color="default"
                  successMessage="Research facility added successfully"
                  errorMessage="Failed to add research facility"
                  tooltip="Add new research facility"
                >
                  New Facility
                </ActionButton>
                <ActionButton
                  action="research_save_data"
                  icon="💾"
                  color="good"
                  successMessage="Research data saved successfully"
                  errorMessage="Failed to save research data"
                  tooltip="Save research data"
                >
                  Save Data
                </ActionButton>
                <ActionButton
                  action="research_load_data"
                  icon="📂"
                  color="default"
                  successMessage="Research data loaded successfully"
                  errorMessage="Failed to load research data"
                  tooltip="Load research data"
                >
                  Load Data
                </ActionButton>
                <EnhancedButton
                  icon="🔬"
                  color="blue"
                  onClick={() => {
                    addNotification(
                      'Research Analysis',
                      'Analyzing research data...',
                      'info',
                    );
                    setTimeout(
                      () =>
                        addNotification(
                          'Research Analysis',
                          'Research analysis completed',
                          'success',
                        ),
                      2500,
                    );
                  }}
                  tooltip="Analyze research data"
                >
                  Analyze
                </EnhancedButton>
                <EnhancedButton
                  icon="📊"
                  color="average"
                  onClick={() => {
                    addNotification(
                      'Research Report',
                      'Generating research report...',
                      'info',
                    );
                    setTimeout(
                      () =>
                        addNotification(
                          'Research Report',
                          'Research report generated',
                          'success',
                        ),
                      2000,
                    );
                  }}
                  tooltip="Generate research report"
                >
                  Report
                </EnhancedButton>
              </Flex>
            </Section>
          </Box>
        )}

        {/* Projects Tab */}
        {researchActiveTab === 'projects' && (
          <Box>
            <Section title="Research Projects">
              <Box className="scrollable-table">
                <Table>
                  <Table.Row header>
                    <Table.Cell>Project Name</Table.Cell>
                    <Table.Cell>Field</Table.Cell>
                    <Table.Cell>Lead Researcher</Table.Cell>
                    <Table.Cell>Progress</Table.Cell>
                    <Table.Cell>Status</Table.Cell>
                    <Table.Cell>Actions</Table.Cell>
                  </Table.Row>
                  {/* Real project data from backend */}
                  {research_data?.research_projects &&
                  research_data.research_projects.length > 0 ? (
                    research_data.research_projects.map((project, index) => (
                      <Table.Row key={index}>
                        <Table.Cell>{project.project_name}</Table.Cell>
                        <Table.Cell>{project.field}</Table.Cell>
                        <Table.Cell>{project.lead_researcher}</Table.Cell>
                        <Table.Cell>
                          <ProgressBar
                            value={project.progress}
                            maxValue={100}
                            color={
                              project.progress >= 80
                                ? 'good'
                                : project.progress >= 50
                                  ? 'blue'
                                  : 'bad'
                            }
                          />
                        </Table.Cell>
                        <Table.Cell>
                          <Box
                            style={{
                              color:
                                project.status === 'COMPLETED'
                                  ? '#66ff66'
                                  : project.status === 'ACTIVE'
                                    ? '#66ffff'
                                    : '#ffaa00',
                              fontWeight: 'bold',
                            }}
                          >
                            {project.status}
                          </Box>
                        </Table.Cell>
                        <Table.Cell>
                          <Button
                            size="small"
                            onClick={() =>
                              setSelectedProject(project.project_name)
                            }
                          >
                            {project.status === 'COMPLETED'
                              ? 'View'
                              : 'Details'}
                          </Button>
                        </Table.Cell>
                      </Table.Row>
                    ))
                  ) : (
                    <Table.Row>
                      <Table.Cell
                        colSpan={6}
                        style={{ textAlign: 'center', padding: '20px' }}
                      >
                        No research projects found. Add some projects to get
                        started.
                      </Table.Cell>
                    </Table.Row>
                  )}
                </Table>
              </Box>
            </Section>
          </Box>
        )}

        {/* Discoveries Tab */}
        {researchActiveTab === 'discoveries' && (
          <Box>
            <Section title="Scientific Discoveries">
              <Table>
                <Table.Row header>
                  <Table.Cell>Discovery Name</Table.Cell>
                  <Table.Cell>Field</Table.Cell>
                  <Table.Cell>Significance</Table.Cell>
                  <Table.Cell>Discoverer</Table.Cell>
                  <Table.Cell>Date</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                {/* Real scientific discoveries data from backend */}
                {research_data?.scientific_discoveries &&
                research_data.scientific_discoveries.length > 0 ? (
                  research_data.scientific_discoveries.map(
                    (discovery, index) => (
                      <Table.Row key={index}>
                        <Table.Cell>{discovery.discovery_name}</Table.Cell>
                        <Table.Cell>{discovery.field}</Table.Cell>
                        <Table.Cell>
                          <ProgressBar
                            value={discovery.significance}
                            maxValue={5}
                            color={
                              discovery.significance >= 4
                                ? 'bad'
                                : discovery.significance >= 2
                                  ? 'average'
                                  : 'good'
                            }
                          />
                        </Table.Cell>
                        <Table.Cell>{discovery.discoverer}</Table.Cell>
                        <Table.Cell>{discovery.date}</Table.Cell>
                        <Table.Cell>
                          <Button
                            size="small"
                            onClick={() =>
                              setSelectedDiscovery(discovery.discovery_name)
                            }
                          >
                            Details
                          </Button>
                        </Table.Cell>
                      </Table.Row>
                    ),
                  )
                ) : (
                  <Table.Row>
                    <Table.Cell
                      colSpan={6}
                      style={{ textAlign: 'center', padding: '20px' }}
                    >
                      No scientific discoveries found.
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Section>
          </Box>
        )}

        {/* Publications Tab */}
        {researchActiveTab === 'publications' && (
          <Box>
            <Section title="Research Publications">
              <Table>
                <Table.Row header>
                  <Table.Cell>Title</Table.Cell>
                  <Table.Cell>Authors</Table.Cell>
                  <Table.Cell>Journal</Table.Cell>
                  <Table.Cell>Impact Factor</Table.Cell>
                  <Table.Cell>Date</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                {/* Real publications data from backend */}
                {research_data?.publications &&
                research_data.publications.length > 0 ? (
                  research_data.publications.map((publication, index) => (
                    <Table.Row key={index}>
                      <Table.Cell>{publication.title}</Table.Cell>
                      <Table.Cell>{publication.authors}</Table.Cell>
                      <Table.Cell>{publication.journal}</Table.Cell>
                      <Table.Cell>{publication.impact_factor}</Table.Cell>
                      <Table.Cell>{publication.date}</Table.Cell>
                      <Table.Cell>
                        <Button
                          size="small"
                          onClick={() =>
                            setSelectedPublication(publication.title)
                          }
                        >
                          View
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  ))
                ) : (
                  <Table.Row>
                    <Table.Cell
                      colSpan={6}
                      style={{ textAlign: 'center', padding: '20px' }}
                    >
                      No publications found.
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Section>
          </Box>
        )}

        {/* Facilities Tab */}
        {researchActiveTab === 'facilities' && (
          <Box>
            <Section title="Research Facilities">
              <Table>
                <Table.Row header>
                  <Table.Cell>Facility Name</Table.Cell>
                  <Table.Cell>Type</Table.Cell>
                  <Table.Cell>Capacity</Table.Cell>
                  <Table.Cell>Utilization</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                {/* Real facility data from backend */}
                {facility_data && Object.keys(facility_data).length > 0 ? (
                  <Table.Row>
                    <Table.Cell>Main Facility</Table.Cell>
                    <Table.Cell>Research Complex</Table.Cell>
                    <Table.Cell>
                      {facility_data.room_states_count || 0} Rooms
                    </Table.Cell>
                    <Table.Cell>
                      <ProgressBar
                        value={facility_data.facility_health || 0}
                        maxValue={100}
                        color={
                          (facility_data.facility_health || 0) >= 80
                            ? 'good'
                            : (facility_data.facility_health || 0) >= 60
                              ? 'average'
                              : 'bad'
                        }
                      />
                    </Table.Cell>
                    <Table.Cell>
                      <Box style={{ color: '#66ff66', fontWeight: 'bold' }}>
                        OPERATIONAL
                      </Box>
                    </Table.Cell>
                    <Table.Cell>
                      <Button
                        size="small"
                        onClick={() => setSelectedFacility('main_facility')}
                      >
                        Manage
                      </Button>
                    </Table.Cell>
                  </Table.Row>
                ) : (
                  <Table.Row>
                    <Table.Cell
                      colSpan={6}
                      style={{ textAlign: 'center', padding: '20px' }}
                    >
                      No facility data available.
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Section>
          </Box>
        )}

        {/* Detail Modals */}
        {selectedProject && (
          <Modal>
            <Section title={`Project Details: ${selectedProject}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Project:</strong> {selectedProject}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> Active
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Progress:</strong> 0%
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  Project details will be populated from research data.
                </Box>
              </Box>
              <Button onClick={() => setSelectedProject(null)}>Close</Button>
            </Section>
          </Modal>
        )}

        {selectedDiscovery && (
          <Modal>
            <Section title={`Discovery Details: ${selectedDiscovery}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Discovery:</strong> {selectedDiscovery}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> Verified
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Date:</strong> {new Date().toLocaleDateString()}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  Discovery details will be populated from research data.
                </Box>
              </Box>
              <Button onClick={() => setSelectedDiscovery(null)}>Close</Button>
            </Section>
          </Modal>
        )}

        {selectedPublication && (
          <Modal>
            <Section title={`Publication Details: ${selectedPublication}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Publication:</strong> {selectedPublication}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> Published
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Date:</strong> {new Date().toLocaleDateString()}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  Publication details will be populated from research data.
                </Box>
              </Box>
              <Button onClick={() => setSelectedPublication(null)}>
                Close
              </Button>
            </Section>
          </Modal>
        )}

        {selectedFacility && selectedFacility !== 'research' && (
          <Modal>
            <Section title={`Facility Details: ${selectedFacility}`}>
              <Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Facility:</strong> {selectedFacility}
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Status:</strong> Operational
                </Box>
                <Box style={{ marginBottom: '10px' }}>
                  <strong>Type:</strong> Research Facility
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                  Facility details will be populated from facility data.
                </Box>
              </Box>
              <Button onClick={() => setSelectedFacility(null)}>Close</Button>
            </Section>
          </Modal>
        )}
      </Box>
    );
  };

  // Budget Management Interface
  const BudgetInterface = ({
    budgetModal,
    setBudgetModal,
    budgetRequestModal,
    setBudgetRequestModal,
    budgetTransferModal,
    setBudgetTransferModal,
    budgetReportModal,
    setBudgetReportModal,
    budgetFormData,
    setBudgetFormData,
    budgetRequestData,
    setBudgetRequestData,
    budgetTransferData,
    setBudgetTransferData,
  }) => {
    return (
      <Box
        style={{
          background: 'rgba(0,0,0,0.7)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: '5px',
          padding: '20px',
          fontFamily: 'monospace',
          fontSize: '14px',
          color: '#ffffff',
          minHeight: '100%',
          position: 'relative',
        }}
      >
        {/* Back to Desktop Button */}
        <Box
          style={{
            position: 'absolute',
            top: '10px',
            right: '10px',
            padding: '8px 16px',
            background: 'rgba(255,255,255,0.1)',
            border: '1px solid rgba(255,255,255,0.3)',
            borderRadius: '5px',
            cursor: 'pointer',
            fontSize: '12px',
            transition: 'all 0.3s ease',
          }}
          onClick={() => setActiveTab('desktop')}
          onMouseEnter={(e) => {
            e.target.style.background = 'rgba(255,255,255,0.2)';
          }}
          onMouseLeave={(e) => {
            e.target.style.background = 'rgba(255,255,255,0.1)';
          }}
        >
          ← BACK TO DESKTOP
        </Box>
        <Box style={{ marginBottom: '20px' }}>
          <Box
            style={{
              fontSize: '24px',
              fontWeight: 'bold',
              marginBottom: '5px',
            }}
          >
            BUDGET MANAGEMENT
          </Box>
          <Box style={{ fontSize: '16px', opacity: 0.8 }}>
            FINANCIAL CONTROL & ALLOCATION
          </Box>
        </Box>

        {/* Budget Navigation Tabs */}
        <Flex
          style={{
            marginBottom: '20px',
            borderBottom: '1px solid rgba(255,255,255,0.3)',
          }}
        >
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom: '2px solid #66ff66',
              color: '#66ff66',
            }}
          >
            OVERVIEW
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom: 'none',
              color: '#ffffff',
            }}
          >
            TRANSACTIONS
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom: 'none',
              color: '#ffffff',
            }}
          >
            REQUESTS
          </Box>
          <Box
            style={{
              padding: '10px 20px',
              cursor: 'pointer',
              borderBottom: 'none',
              color: '#ffffff',
            }}
          >
            REPORTS
          </Box>
        </Flex>

        {/* Budget Overview */}
        <Box style={{ marginBottom: '30px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            BUDGET OVERVIEW:
          </Box>
          <Grid>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(0,255,0,0.1)',
                  padding: '15px',
                  borderRadius: '5px',
                  marginBottom: '10px',
                }}
              >
                <Box
                  style={{
                    fontSize: '16px',
                    fontWeight: 'bold',
                    color: '#66ff66',
                  }}
                >
                  TOTAL BUDGET
                </Box>
                <Box style={{ fontSize: '20px' }}>
                  ${(budget_data?.total_budget || 0).toLocaleString()}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.8 }}>Credits</Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,165,0,0.1)',
                  padding: '15px',
                  borderRadius: '5px',
                  marginBottom: '10px',
                }}
              >
                <Box
                  style={{
                    fontSize: '16px',
                    fontWeight: 'bold',
                    color: '#ffaa66',
                  }}
                >
                  CURRENT BALANCE
                </Box>
                <Box style={{ fontSize: '20px' }}>
                  ${(budget_data?.current_balance || 0).toLocaleString()}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.8 }}>Available</Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(255,0,0,0.1)',
                  padding: '15px',
                  borderRadius: '5px',
                  marginBottom: '10px',
                }}
              >
                <Box
                  style={{
                    fontSize: '16px',
                    fontWeight: 'bold',
                    color: '#ff6666',
                  }}
                >
                  MONTHLY EXPENSES
                </Box>
                <Box style={{ fontSize: '20px' }}>
                  ${(budget_data?.monthly_expenses || 0).toLocaleString()}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.8 }}>Spent</Box>
              </Box>
            </Grid.Column>
            <Grid.Column size={3}>
              <Box
                style={{
                  background: 'rgba(0,255,255,0.1)',
                  padding: '15px',
                  borderRadius: '5px',
                  marginBottom: '10px',
                }}
              >
                <Box
                  style={{
                    fontSize: '16px',
                    fontWeight: 'bold',
                    color: '#66ffff',
                  }}
                >
                  MONTHLY REVENUE
                </Box>
                <Box style={{ fontSize: '20px' }}>
                  ${(budget_data?.monthly_revenue || 0).toLocaleString()}
                </Box>
                <Box style={{ fontSize: '12px', opacity: 0.8 }}>Earned</Box>
              </Box>
            </Grid.Column>
          </Grid>
        </Box>

        {/* Budget Controls */}
        <Box style={{ marginBottom: '20px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            BUDGET CONTROLS:
          </Box>
          <Flex wrap="wrap" style={{ gap: '10px', marginBottom: '20px' }}>
            <EnhancedButton
              icon="💰"
              color="good"
              onClick={() => setBudgetModal(true)}
              tooltip="Add new transaction to budget system"
            >
              ADD TRANSACTION
            </EnhancedButton>
            <EnhancedButton
              icon="📋"
              color="blue"
              onClick={() => setBudgetRequestModal(true)}
              tooltip="Request budget increase for department"
            >
              REQUEST BUDGET
            </EnhancedButton>
            <EnhancedButton
              icon="🔄"
              color="average"
              onClick={() => setBudgetTransferModal(true)}
              tooltip="Transfer budget between departments"
            >
              TRANSFER BUDGET
            </EnhancedButton>
            <EnhancedButton
              icon="📊"
              color="purple"
              onClick={() => setBudgetReportModal(true)}
              tooltip="Generate comprehensive budget report"
            >
              BUDGET REPORT
            </EnhancedButton>
          </Flex>
        </Box>

        {/* Department Budgets */}
        <Box style={{ marginBottom: '30px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            DEPARTMENT BUDGETS:
          </Box>
          <Grid>
            {budget_data?.departments &&
              Object.entries(budget_data.departments).map(([deptId, dept]) => (
                <Grid.Column key={deptId} size={4}>
                  <Box
                    style={{
                      background: 'rgba(255,255,255,0.05)',
                      padding: '15px',
                      borderRadius: '5px',
                      marginBottom: '10px',
                      border: '1px solid rgba(255,255,255,0.1)',
                    }}
                  >
                    <Box
                      style={{
                        fontSize: '14px',
                        fontWeight: 'bold',
                        marginBottom: '5px',
                      }}
                    >
                      {dept.name}
                    </Box>
                    <Box style={{ fontSize: '12px', marginBottom: '10px' }}>
                      <Box>
                        Allocated: ${dept.allocated?.toLocaleString() || 0}
                      </Box>
                      <Box>Spent: ${dept.spent?.toLocaleString() || 0}</Box>
                      <Box>
                        Remaining: ${dept.remaining?.toLocaleString() || 0}
                      </Box>
                      <Box>Efficiency: {dept.efficiency || 0}%</Box>
                      <Box
                        style={{
                          color:
                            dept.status === 'NORMAL'
                              ? '#66ff66'
                              : dept.status === 'WARNING'
                                ? '#ffff00'
                                : dept.status === 'CRITICAL'
                                  ? '#ff6600'
                                  : '#ff0000',
                          fontWeight: 'bold',
                        }}
                      >
                        Status: {dept.status}
                      </Box>
                    </Box>
                  </Box>
                </Grid.Column>
              ))}
          </Grid>
        </Box>

        {/* Recent Transactions */}
        <Box style={{ marginBottom: '30px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            RECENT TRANSACTIONS:
          </Box>
          <Box
            style={{
              background: 'rgba(0,0,0,0.5)',
              padding: '15px',
              borderRadius: '5px',
              maxHeight: '200px',
              overflowY: 'auto',
            }}
          >
            {budget_data?.recent_transactions &&
            budget_data.recent_transactions.length > 0 ? (
              budget_data.recent_transactions.map((transaction, index) => (
                <Box
                  key={index}
                  style={{
                    padding: '8px',
                    borderBottom: '1px solid rgba(255,255,255,0.1)',
                    fontSize: '12px',
                  }}
                >
                  <Box
                    style={{ display: 'flex', justifyContent: 'space-between' }}
                  >
                    <Box>
                      <Box style={{ fontWeight: 'bold' }}>
                        {transaction.type} - {transaction.department}
                      </Box>
                      <Box style={{ opacity: 0.8 }}>
                        {transaction.description}
                      </Box>
                    </Box>
                    <Box
                      style={{
                        color:
                          transaction.type === 'EXPENSE'
                            ? '#ff6666'
                            : '#66ff66',
                        fontWeight: 'bold',
                      }}
                    >
                      ${transaction.amount?.toLocaleString() || 0}
                    </Box>
                  </Box>
                  <Box style={{ fontSize: '10px', opacity: 0.6 }}>
                    {transaction.timestamp}
                  </Box>
                </Box>
              ))
            ) : (
              <Box style={{ opacity: 0.7, textAlign: 'center' }}>
                No recent transactions
              </Box>
            )}
          </Box>
        </Box>

        {/* Budget Alerts */}
        <Box style={{ marginBottom: '30px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            BUDGET ALERTS:
          </Box>
          <Box
            style={{
              background: 'rgba(0,0,0,0.5)',
              padding: '15px',
              borderRadius: '5px',
              maxHeight: '200px',
              overflowY: 'auto',
            }}
          >
            {budget_data?.budget_alerts &&
            budget_data.budget_alerts.length > 0 ? (
              budget_data.budget_alerts.map((alert, index) => (
                <Box
                  key={index}
                  style={{
                    padding: '8px',
                    borderBottom: '1px solid rgba(255,255,255,0.1)',
                    fontSize: '12px',
                    borderLeft: `3px solid ${
                      alert.type === 'CRITICAL'
                        ? '#ff0000'
                        : alert.type === 'WARNING'
                          ? '#ffff00'
                          : '#00ff00'
                    }`,
                  }}
                >
                  <Box
                    style={{ display: 'flex', justifyContent: 'space-between' }}
                  >
                    <Box>
                      <Box
                        style={{
                          fontWeight: 'bold',
                          color:
                            alert.type === 'CRITICAL'
                              ? '#ff6666'
                              : alert.type === 'WARNING'
                                ? '#ffff66'
                                : '#66ff66',
                        }}
                      >
                        {alert.type} - {alert.department}
                      </Box>
                      <Box style={{ opacity: 0.8 }}>{alert.message}</Box>
                    </Box>
                    <Box style={{ fontSize: '10px', opacity: 0.6 }}>
                      Severity: {alert.severity}/5
                    </Box>
                  </Box>
                  <Box style={{ fontSize: '10px', opacity: 0.6 }}>
                    {alert.timestamp}
                  </Box>
                </Box>
              ))
            ) : (
              <Box style={{ opacity: 0.7, textAlign: 'center' }}>
                No active budget alerts
              </Box>
            )}
          </Box>
        </Box>

        {/* Pending Requests */}
        <Box style={{ marginBottom: '30px' }}>
          <Box style={{ marginBottom: '15px', fontWeight: 'bold' }}>
            PENDING BUDGET REQUESTS:
          </Box>
          <Box
            style={{
              background: 'rgba(0,0,0,0.5)',
              padding: '15px',
              borderRadius: '5px',
              maxHeight: '200px',
              overflowY: 'auto',
            }}
          >
            {budget_data?.pending_requests &&
            budget_data.pending_requests.length > 0 ? (
              budget_data.pending_requests.map((request, index) => (
                <Box
                  key={index}
                  style={{
                    padding: '8px',
                    borderBottom: '1px solid rgba(255,255,255,0.1)',
                    fontSize: '12px',
                  }}
                >
                  <Box
                    style={{ display: 'flex', justifyContent: 'space-between' }}
                  >
                    <Box>
                      <Box style={{ fontWeight: 'bold' }}>
                        {request.department} - $
                        {request.amount?.toLocaleString() || 0}
                      </Box>
                      <Box style={{ opacity: 0.8 }}>
                        {request.justification}
                      </Box>
                    </Box>
                    <Box style={{ fontSize: '10px', opacity: 0.6 }}>
                      Priority: {request.priority}
                    </Box>
                  </Box>
                  <Box style={{ fontSize: '10px', opacity: 0.6 }}>
                    Requested by: {request.requested_by} - {request.timestamp}
                  </Box>
                </Box>
              ))
            ) : (
              <Box style={{ opacity: 0.7, textAlign: 'center' }}>
                No pending budget requests
              </Box>
            )}
          </Box>
        </Box>
      </Box>
    );
  };

  // Personnel Management Interface
  const PersonnelInterface = ({
    personnelActiveTab,
    setPersonnelActiveTab,
  }) => {
    const [selectedEmployee, setSelectedEmployee] = useLocalState(
      context,
      'personnelSelectedEmployee',
      null,
    );
    const [selectedDepartment, setSelectedDepartment] = useLocalState(
      context,
      'personnelSelectedDepartment',
      null,
    );
    const [selectedTraining, setSelectedTraining] = useLocalState(
      context,
      'personnelSelectedTraining',
      null,
    );
    const [selectedPerformance, setSelectedPerformance] = useLocalState(
      context,
      'personnelSelectedPerformance',
      null,
    );
    const [searchTerm, setSearchTerm] = useLocalState(
      context,
      'personnelSearchTerm',
      '',
    );
    const [filterType, setFilterType] = useLocalState(
      context,
      'personnelFilterType',
      'all',
    );

    return (
      <Box
        style={{
          background: 'rgba(0,0,0,0.7)',
          border: '1px solid rgba(255,255,255,0.2)',
          borderRadius: '5px',
          padding: '20px',
          fontFamily: 'monospace',
          fontSize: '14px',
          color: '#ffffff',
          minHeight: '100%',
          position: 'relative',
        }}
      >
        {/* Back to Desktop Button */}
        <Box
          style={{
            position: 'absolute',
            top: '10px',
            right: '10px',
            padding: '8px 16px',
            background: 'rgba(255,255,255,0.1)',
            border: '1px solid rgba(255,255,255,0.3)',
            borderRadius: '5px',
            cursor: 'pointer',
            fontSize: '12px',
            transition: 'all 0.3s ease',
          }}
          onClick={() => setActiveTab('desktop')}
          onMouseEnter={(e) => {
            e.target.style.background = 'rgba(255,255,255,0.2)';
          }}
          onMouseLeave={(e) => {
            e.target.style.background = 'rgba(255,255,255,0.1)';
          }}
        >
          ← BACK TO DESKTOP
        </Box>
        <Box style={{ marginBottom: '20px' }}>
          <Box
            style={{
              fontSize: '24px',
              fontWeight: 'bold',
              marginBottom: '5px',
            }}
          >
            PERSONNEL PERSISTENCE
          </Box>
          <Box style={{ fontSize: '16px', opacity: 0.8 }}>
            STAFF & ASSIGNMENTS
          </Box>
        </Box>

        {/* Personnel Navigation Tabs */}
        <Flex
          style={{
            marginBottom: '20px',
            borderBottom: '1px solid rgba(255,255,255,0.3)',
            gap: '5px',
          }}
        >
          <NavButton
            isActive={personnelActiveTab === 'overview'}
            onClick={() => setPersonnelActiveTab('overview')}
            icon="📊"
          >
            OVERVIEW
          </NavButton>
          <NavButton
            isActive={personnelActiveTab === 'employees'}
            onClick={() => setPersonnelActiveTab('employees')}
            icon="👥"
          >
            EMPLOYEES
          </NavButton>
          <NavButton
            isActive={personnelActiveTab === 'departments'}
            onClick={() => setPersonnelActiveTab('departments')}
            icon="🏢"
          >
            DEPARTMENTS
          </NavButton>
          <NavButton
            isActive={personnelActiveTab === 'training'}
            onClick={() => setPersonnelActiveTab('training')}
            icon="🎓"
          >
            TRAINING
          </NavButton>
          <NavButton
            isActive={personnelActiveTab === 'performance'}
            onClick={() => setPersonnelActiveTab('performance')}
            icon="📈"
          >
            PERFORMANCE
          </NavButton>
        </Flex>

        {/* Overview Tab */}
        {personnelActiveTab === 'overview' && (
          <Box>
            <Box
              style={{
                fontSize: '12px',
                opacity: 0.7,
                textAlign: 'center',
                marginTop: '20px',
              }}
            >
              Personnel system overview - all systems operational.
            </Box>

            <Section title="Quick Actions">
              <Flex wrap="wrap" style={{ gap: '10px' }}>
                <EnhancedButton
                  icon="👤"
                  color="good"
                  onClick={() => setPersonnelModalOpen(true)}
                  tooltip="Open detailed employee registration form"
                >
                  Add Employee
                </EnhancedButton>
                <ActionButton
                  action="personnel_add_department"
                  icon="🏢"
                  color="blue"
                  successMessage="Department added successfully"
                  errorMessage="Failed to add department"
                  tooltip="Add new department"
                >
                  New Department
                </ActionButton>
                <ActionButton
                  action="personnel_add_training"
                  icon="🎓"
                  color="purple"
                  successMessage="Training scheduled successfully"
                  errorMessage="Failed to schedule training"
                  tooltip="Schedule training session"
                >
                  Schedule Training
                </ActionButton>
                <ActionButton
                  action="personnel_add_performance"
                  icon="📈"
                  color="average"
                  successMessage="Performance review added successfully"
                  errorMessage="Failed to add performance review"
                  tooltip="Add performance review"
                >
                  Performance Review
                </ActionButton>
                <ActionButton
                  action="personnel_save_data"
                  icon="💾"
                  color="default"
                  successMessage="Personnel data saved successfully"
                  errorMessage="Failed to save personnel data"
                  tooltip="Save personnel data"
                >
                  Save Data
                </ActionButton>
                <ActionButton
                  action="personnel_load_data"
                  icon="📂"
                  color="default"
                  successMessage="Personnel data loaded successfully"
                  errorMessage="Failed to load personnel data"
                  tooltip="Load personnel data"
                >
                  Load Data
                </ActionButton>
                <EnhancedButton
                  icon="📤"
                  color="blue"
                  onClick={() => {
                    addNotification(
                      'Export',
                      'Exporting personnel data...',
                      'info',
                    );
                    setTimeout(
                      () =>
                        addNotification(
                          'Export',
                          'Personnel data exported successfully',
                          'success',
                        ),
                      1500,
                    );
                  }}
                  tooltip="Export personnel data"
                >
                  Export
                </EnhancedButton>
                <EnhancedButton
                  icon="📥"
                  color="blue"
                  onClick={() => {
                    addNotification(
                      'Import',
                      'Importing personnel data...',
                      'info',
                    );
                    setTimeout(
                      () =>
                        addNotification(
                          'Import',
                          'Personnel data imported successfully',
                          'success',
                        ),
                      1500,
                    );
                  }}
                  tooltip="Import personnel data"
                >
                  Import
                </EnhancedButton>
              </Flex>
            </Section>
          </Box>
        )}

        {/* Employees Tab */}
        {personnelActiveTab === 'employees' && (
          <Box>
            <Section title="Employee Records">
              {/* Search and Filter Controls */}
              <Box style={{ marginBottom: '15px' }}>
                <Flex style={{ gap: '10px', marginBottom: '10px' }}>
                  <Box style={{ flex: 1 }}>
                    <input
                      type="text"
                      placeholder="Search employees..."
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      style={{
                        width: '100%',
                        padding: '8px',
                        background: 'rgba(0,0,0,0.5)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        color: '#ffffff',
                        fontFamily: 'monospace',
                        fontSize: '12px',
                      }}
                    />
                  </Box>
                  <Box>
                    <select
                      value={filterType}
                      onChange={(e) => setFilterType(e.target.value)}
                      style={{
                        padding: '8px',
                        background: 'rgba(0,0,0,0.5)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        color: '#ffffff',
                        fontFamily: 'monospace',
                        fontSize: '12px',
                      }}
                    >
                      <option value="all">All Employees</option>
                      <option value="active">Active</option>
                      <option value="resigned">Resigned</option>
                      <option value="promoted">Recently Promoted</option>
                    </select>
                  </Box>
                  <Button
                    onClick={() => act('personnel_export_employees')}
                    icon="download"
                    size="small"
                    color="blue"
                  >
                    Export
                  </Button>
                  <Button
                    onClick={() => act('personnel_bulk_actions')}
                    icon="tasks"
                    size="small"
                    color="purple"
                  >
                    Bulk Actions
                  </Button>
                </Flex>
              </Box>

              <Box className="scrollable-table">
                <Table>
                  <Table.Row header>
                    <Table.Cell>
                      <input type="checkbox" style={{ marginRight: '5px' }} />
                    </Table.Cell>
                    <Table.Cell>Name</Table.Cell>
                    <Table.Cell>Department</Table.Cell>
                    <Table.Cell>Position</Table.Cell>
                    <Table.Cell>Performance</Table.Cell>
                    <Table.Cell>Clearance</Table.Cell>
                    <Table.Cell>Status</Table.Cell>
                    <Table.Cell>Actions</Table.Cell>
                  </Table.Row>
                  {/* Real-time employee data */}
                  {personnel_details?.employees &&
                  personnel_details.employees.length > 0 ? (
                    personnel_details.employees.map((employee, index) => (
                      <Table.Row key={index}>
                        <Table.Cell>
                          <input type="checkbox" />
                        </Table.Cell>
                        <Table.Cell>{employee.name}</Table.Cell>
                        <Table.Cell>{employee.department}</Table.Cell>
                        <Table.Cell>{employee.position}</Table.Cell>
                        <Table.Cell>
                          <ProgressBar
                            value={employee.performance}
                            maxValue={100}
                            color={
                              employee.performance >= 80
                                ? 'good'
                                : employee.performance >= 60
                                  ? 'average'
                                  : 'bad'
                            }
                          />
                        </Table.Cell>
                        <Table.Cell>{employee.clearance}</Table.Cell>
                        <Table.Cell>
                          <Box
                            style={{
                              color:
                                employee.status === 'ACTIVE'
                                  ? '#66ff66'
                                  : employee.status === 'RESIGNED'
                                    ? '#ff6666'
                                    : '#ffaa00',
                              fontWeight: 'bold',
                            }}
                          >
                            {employee.status}
                          </Box>
                        </Table.Cell>
                        <Table.Cell>
                          <Flex style={{ gap: '5px' }}>
                            <Button
                              size="small"
                              onClick={() => setSelectedEmployee(employee.name)}
                            >
                              View
                            </Button>
                            <Button
                              size="small"
                              color="blue"
                              onClick={() =>
                                act('personnel_edit_employee', {
                                  employee: employee.name,
                                })
                              }
                            >
                              Edit
                            </Button>
                            <Button
                              size="small"
                              color="green"
                              onClick={() =>
                                act('personnel_promote_employee', {
                                  employee: employee.name,
                                })
                              }
                            >
                              Promote
                            </Button>
                          </Flex>
                        </Table.Cell>
                      </Table.Row>
                    ))
                  ) : (
                    <Table.Row>
                      <Table.Cell
                        colSpan={8}
                        style={{ textAlign: 'center', padding: '20px' }}
                      >
                        No employee records found. Add some employees to get
                        started.
                      </Table.Cell>
                    </Table.Row>
                  )}
                </Table>
              </Box>
            </Section>
          </Box>
        )}

        {/* Departments Tab */}
        {personnelActiveTab === 'departments' && (
          <Box>
            <Section title="Department Management">
              <Table>
                <Table.Row header>
                  <Table.Cell>Department</Table.Cell>
                  <Table.Cell>Head</Table.Cell>
                  <Table.Cell>Staff Count</Table.Cell>
                  <Table.Cell>Budget</Table.Cell>
                  <Table.Cell>Efficiency</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                {/* Real department data from backend */}
                {personnel_details?.departments &&
                personnel_details.departments.length > 0 ? (
                  personnel_details.departments.map((dept, index) => (
                    <Table.Row key={index}>
                      <Table.Cell>{dept.name}</Table.Cell>
                      <Table.Cell>{dept.head}</Table.Cell>
                      <Table.Cell>{dept.staff_count}</Table.Cell>
                      <Table.Cell>{dept.budget}</Table.Cell>
                      <Table.Cell>
                        <ProgressBar
                          value={dept.efficiency}
                          maxValue={100}
                          color={
                            dept.efficiency >= 80
                              ? 'good'
                              : dept.efficiency >= 60
                                ? 'average'
                                : 'bad'
                          }
                        />
                      </Table.Cell>
                      <Table.Cell>
                        <Button
                          size="small"
                          onClick={() => setSelectedDepartment(dept.name)}
                        >
                          Manage
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  ))
                ) : (
                  <Table.Row>
                    <Table.Cell
                      colSpan={6}
                      style={{ textAlign: 'center', padding: '20px' }}
                    >
                      No department data found. Departments will appear here
                      when created.
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Section>
          </Box>
        )}

        {/* Training Tab */}
        {personnelActiveTab === 'training' && (
          <Box>
            <Section title="Training Programs">
              <Table>
                <Table.Row header>
                  <Table.Cell>Program</Table.Cell>
                  <Table.Cell>Instructor</Table.Cell>
                  <Table.Cell>Duration</Table.Cell>
                  <Table.Cell>Completion</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                {/* Real training data from backend */}
                {personnel_details?.training &&
                personnel_details.training.length > 0 ? (
                  personnel_details.training.map((training, index) => (
                    <Table.Row key={index}>
                      <Table.Cell>{training.program}</Table.Cell>
                      <Table.Cell>{training.instructor}</Table.Cell>
                      <Table.Cell>{training.duration}</Table.Cell>
                      <Table.Cell>
                        <ProgressBar
                          value={training.completion}
                          maxValue={100}
                          color={
                            training.completion >= 80
                              ? 'good'
                              : training.completion >= 60
                                ? 'blue'
                                : 'bad'
                          }
                        />
                      </Table.Cell>
                      <Table.Cell>
                        <Box
                          style={{
                            color:
                              training.status === 'COMPLETED'
                                ? '#66ff66'
                                : training.status === 'IN_PROGRESS'
                                  ? '#66ffff'
                                  : '#ffaa00',
                            fontWeight: 'bold',
                          }}
                        >
                          {training.status}
                        </Box>
                      </Table.Cell>
                      <Table.Cell>
                        <Button
                          size="small"
                          onClick={() => setSelectedTraining(training.program)}
                        >
                          Details
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  ))
                ) : (
                  <Table.Row>
                    <Table.Cell
                      colSpan={6}
                      style={{ textAlign: 'center', padding: '20px' }}
                    >
                      No training programs found. Training programs will appear
                      here when scheduled.
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Section>
          </Box>
        )}

        {/* Performance Tab */}
        {personnelActiveTab === 'performance' && (
          <Box>
            <Section title="Performance Reviews">
              <Table>
                <Table.Row header>
                  <Table.Cell>Employee</Table.Cell>
                  <Table.Cell>Reviewer</Table.Cell>
                  <Table.Cell>Rating</Table.Cell>
                  <Table.Cell>Date</Table.Cell>
                  <Table.Cell>Status</Table.Cell>
                  <Table.Cell>Actions</Table.Cell>
                </Table.Row>
                {/* Real performance data from backend */}
                {personnel_details?.performance &&
                personnel_details.performance.length > 0 ? (
                  personnel_details.performance.map((review, index) => (
                    <Table.Row key={index}>
                      <Table.Cell>{review.employee}</Table.Cell>
                      <Table.Cell>{review.reviewer}</Table.Cell>
                      <Table.Cell>
                        <ProgressBar
                          value={review.rating}
                          maxValue={100}
                          color={
                            review.rating >= 80
                              ? 'good'
                              : review.rating >= 60
                                ? 'average'
                                : 'bad'
                          }
                        />
                      </Table.Cell>
                      <Table.Cell>{review.date}</Table.Cell>
                      <Table.Cell>
                        <Box
                          style={{
                            color:
                              review.status === 'COMPLETED'
                                ? '#66ff66'
                                : review.status === 'PENDING'
                                  ? '#ffaa00'
                                  : '#ff6666',
                            fontWeight: 'bold',
                          }}
                        >
                          {review.status}
                        </Box>
                      </Table.Cell>
                      <Table.Cell>
                        <Button
                          size="small"
                          onClick={() =>
                            setSelectedPerformance(review.employee)
                          }
                        >
                          View
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  ))
                ) : (
                  <Table.Row>
                    <Table.Cell
                      colSpan={6}
                      style={{ textAlign: 'center', padding: '20px' }}
                    >
                      No performance reviews found. Performance reviews will
                      appear here when conducted.
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Section>
          </Box>
        )}

        {/* Detail Modals */}
        {selectedEmployee && (
          <Box
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              backgroundColor: 'rgba(0,0,0,0.8)',
              zIndex: 1000,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <Box
              style={{
                background: 'rgba(0,0,0,0.9)',
                border: '1px solid rgba(255,255,255,0.3)',
                borderRadius: '5px',
                padding: '20px',
                minWidth: '400px',
                maxWidth: '600px',
              }}
            >
              <Section title={`Employee Details: ${selectedEmployee}`}>
                <Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Name:</strong> {selectedEmployee}
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Department:</strong> General
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Position:</strong> Staff
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Performance Rating:</strong> 80/100
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Clearance Level:</strong> Level 1
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Status:</strong> Active
                  </Box>
                  <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                    Employee details will be populated from personnel data.
                  </Box>
                </Box>
                <Button
                  onClick={() => {
                    console.log(
                      'Closing employee modal, setting selectedEmployee to null',
                    );
                    console.log('activeTab before close:', activeTab);
                    setSelectedEmployee(null);
                    console.log('activeTab after close:', activeTab);
                  }}
                >
                  Close
                </Button>
              </Section>
            </Box>
          </Box>
        )}

        {selectedDepartment && (
          <Box
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              backgroundColor: 'rgba(0,0,0,0.8)',
              zIndex: 1000,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <Box
              style={{
                background: 'rgba(0,0,0,0.9)',
                border: '1px solid rgba(255,255,255,0.3)',
                borderRadius: '5px',
                padding: '20px',
                minWidth: '400px',
                maxWidth: '600px',
              }}
            >
              <Section title={`Department Details: ${selectedDepartment}`}>
                <Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Department:</strong> {selectedDepartment}
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Head:</strong> Department Head
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Staff Count:</strong> 0
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Budget:</strong> $100,000
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Efficiency:</strong> 85%
                  </Box>
                  <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                    Department details will be populated from personnel data.
                  </Box>
                </Box>
                <Button
                  onClick={() => {
                    console.log(
                      'Closing department modal, setting selectedDepartment to null',
                    );
                    setSelectedDepartment(null);
                  }}
                >
                  Close
                </Button>
              </Section>
            </Box>
          </Box>
        )}

        {selectedTraining && (
          <Box
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              backgroundColor: 'rgba(0,0,0,0.8)',
              zIndex: 1000,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <Box
              style={{
                background: 'rgba(0,0,0,0.9)',
                border: '1px solid rgba(255,255,255,0.3)',
                borderRadius: '5px',
                padding: '20px',
                minWidth: '400px',
                maxWidth: '600px',
              }}
            >
              <Section title={`Training Details: ${selectedTraining}`}>
                <Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Program:</strong> {selectedTraining}
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Instructor:</strong> Training Instructor
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Duration:</strong> 8 weeks
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Completion:</strong> 0%
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Status:</strong> Not Started
                  </Box>
                  <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                    Training details will be populated from personnel data.
                  </Box>
                </Box>
                <Button
                  onClick={() => {
                    console.log(
                      'Closing training modal, setting selectedTraining to null',
                    );
                    setSelectedTraining(null);
                  }}
                >
                  Close
                </Button>
              </Section>
            </Box>
          </Box>
        )}

        {selectedPerformance && (
          <Box
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              backgroundColor: 'rgba(0,0,0,0.8)',
              zIndex: 1000,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <Box
              style={{
                background: 'rgba(0,0,0,0.9)',
                border: '1px solid rgba(255,255,255,0.3)',
                borderRadius: '5px',
                padding: '20px',
                minWidth: '400px',
                maxWidth: '600px',
              }}
            >
              <Section title={`Performance Review: ${selectedPerformance}`}>
                <Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Employee:</strong> {selectedPerformance}
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Reviewer:</strong> Supervisor
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Rating:</strong> 85/100
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Date:</strong> Never
                  </Box>
                  <Box style={{ marginBottom: '10px' }}>
                    <strong>Status:</strong> Pending
                  </Box>
                  <Box style={{ fontSize: '12px', opacity: 0.7 }}>
                    Performance review details will be populated from personnel
                    data.
                  </Box>
                </Box>
                <Button
                  onClick={() => {
                    console.log(
                      'Closing performance modal, setting selectedPerformance to null',
                    );
                    setSelectedPerformance(null);
                  }}
                >
                  Close
                </Button>
              </Section>
            </Box>
          </Box>
        )}
      </Box>
    );
  };

  // Right side panel
  const SidePanel = () => (
    <Box
      style={{
        position: 'absolute',
        top: '50px',
        right: '20px',
        width: scipnetCollapsed ? '60px' : '360px',
        bottom: '20px',
        background: 'rgba(0,0,0,0.7)',
        border: '1px solid rgba(255,255,255,0.2)',
        borderRadius: '5px',
        padding: scipnetCollapsed ? '10px' : '20px',
        fontFamily: 'monospace',
        fontSize: '12px',
        color: '#ffffff',
        zIndex: 5,
        transition: 'all 0.3s ease',
      }}
    >
      {/* Redacted Information */}
      {!scipnetCollapsed && (
        <>
          <Box style={{ marginBottom: '20px' }}>
            <Box style={{ marginBottom: '5px' }}>
              COUNTRY: <span style={{ color: '#ff0000' }}>[REDACTED]</span>
            </Box>
            <Box style={{ marginBottom: '5px' }}>
              REGION: <span style={{ color: '#ff0000' }}>[REDACTED]</span>
            </Box>
            <Box>
              IP ADDRESS: <span style={{ color: '#ff0000' }}>[REDACTED]</span>
            </Box>
          </Box>

          {/* Network Map Placeholder */}
          <Box
            style={{
              width: '100%',
              height: '120px',
              background:
                'linear-gradient(45deg, rgba(255,255,255,0.1) 25%, transparent 25%), linear-gradient(-45deg, rgba(255,255,255,0.1) 25%, transparent 25%), linear-gradient(45deg, transparent 75%, rgba(255,255,255,0.1) 75%), linear-gradient(-45deg, transparent 75%, rgba(255,255,255,0.1) 75%)',
              backgroundSize: '20px 20px',
              backgroundPosition: '0 0, 0 10px, 10px -10px, -10px 0px',
              marginBottom: '20px',
              border: '1px solid rgba(255,255,255,0.2)',
            }}
          />
        </>
      )}

      {/* SCIPNET Title */}
      <Box
        style={{
          fontSize: scipnetCollapsed ? '12px' : '24px',
          fontWeight: 'bold',
          textAlign: 'center',
          marginBottom: scipnetCollapsed ? '0' : '20px',
          cursor: 'pointer',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          gap: '8px',
        }}
        onClick={() => setScipnetCollapsed(!scipnetCollapsed)}
      >
        {scipnetCollapsed ? (
          <>
            <Box style={{ transform: 'rotate(90deg)', fontSize: '14px' }}>
              ▶
            </Box>
            <Box style={{ transform: 'rotate(90deg)', fontSize: '10px' }}>
              SCIPNET
            </Box>
          </>
        ) : (
          <>
            <Box>SCIPNET</Box>
            <Box
              style={{
                fontSize: '12px',
                cursor: 'pointer',
                padding: '2px 6px',
                background: 'rgba(255,255,255,0.1)',
                borderRadius: '3px',
                marginLeft: 'auto',
              }}
              onClick={(e) => {
                e.stopPropagation();
                setScipnetCollapsed(true);
              }}
            >
              −
            </Box>
          </>
        )}
      </Box>

      {/* System Overview */}
      {!scipnetCollapsed && (
        <>
          <Box style={{ marginBottom: '20px' }}>
            <Box style={{ marginBottom: '10px', fontWeight: 'bold' }}>
              SYSTEM OVERVIEW
            </Box>
            <Box style={{ fontSize: '10px', lineHeight: '1.4' }}>
              <Box>
                FACILITY:{' '}
                <DataStatusIndicator data={facility_data} label="FACILITY" />
              </Box>
              <Box>
                SCP: <DataStatusIndicator data={scp_data} label="SCP" />
              </Box>
              <Box>
                TECHNOLOGY:{' '}
                <DataStatusIndicator data={technology_data} label="TECH" />
              </Box>
              <Box>
                MEDICAL:{' '}
                <DataStatusIndicator data={medical_data} label="MEDICAL" />
              </Box>
              <Box>
                SECURITY:{' '}
                <DataStatusIndicator data={security_data} label="SECURITY" />
              </Box>
              <Box>
                RESEARCH:{' '}
                <DataStatusIndicator data={research_data} label="RESEARCH" />
              </Box>
              <Box>
                PERSONNEL:{' '}
                <DataStatusIndicator data={personnel_data} label="PERSONNEL" />
              </Box>
              <Box>
                PLAYER:{' '}
                <DataStatusIndicator data={player_data} label="PLAYER" />
              </Box>
            </Box>

            {/* Key Metrics Summary */}
            <Box style={{ marginTop: '10px', fontSize: '9px', opacity: 0.8 }}>
              <Box style={{ marginBottom: '5px', fontWeight: 'bold' }}>
                KEY METRICS:
              </Box>
              <Box>ACTIVE THREATS: {security_data?.active_threats || 0}</Box>
              <Box>OUTBREAKS: {medical_data?.active_outbreaks || 0}</Box>
              <Box>BREACHES: {security_data?.containment_breaches || 0}</Box>
              <Box>STAFF: {personnel_data?.active_staff || 0}</Box>
              <Box>PROJECTS: {research_data?.active_projects || 0}</Box>
              <Box>PLAYERS: {player_data?.active_players || 0}</Box>
            </Box>

            {/* Real-time Notifications */}
            <Box style={{ marginTop: '20px' }}>
              <Box
                style={{
                  marginBottom: '10px',
                  fontWeight: 'bold',
                  color: '#ff6666',
                }}
              >
                🚨 LIVE ALERTS
              </Box>
              <Box style={{ fontSize: '8px', lineHeight: '1.3' }}>
                {notifications && notifications.length > 0 ? (
                  notifications.map((notification, index) => (
                    <Box
                      key={index}
                      style={{
                        background:
                          notification.type === 'CRITICAL'
                            ? 'rgba(255,0,0,0.2)'
                            : notification.type === 'WARNING'
                              ? 'rgba(255,255,0,0.2)'
                              : 'rgba(0,255,0,0.2)',
                        padding: '5px',
                        marginBottom: '5px',
                        border:
                          notification.type === 'CRITICAL'
                            ? '1px solid rgba(255,0,0,0.5)'
                            : notification.type === 'WARNING'
                              ? '1px solid rgba(255,255,0,0.5)'
                              : '1px solid rgba(0,255,0,0.5)',
                        borderRadius: '3px',
                      }}
                    >
                      <Box
                        style={{
                          color:
                            notification.type === 'CRITICAL'
                              ? '#ff6666'
                              : notification.type === 'WARNING'
                                ? '#ffff66'
                                : '#66ff66',
                          fontWeight: 'bold',
                        }}
                      >
                        {notification.type === 'CRITICAL'
                          ? '⚠️ CRITICAL'
                          : notification.type === 'WARNING'
                            ? '⚠️ WARNING'
                            : '✅ INFO'}
                      </Box>
                      <Box>{notification.message}</Box>
                      <Box style={{ fontSize: '7px', opacity: '0.7' }}>
                        {notification.time}
                      </Box>
                    </Box>
                  ))
                ) : (
                  <Box
                    style={{
                      background: 'rgba(0,255,0,0.2)',
                      padding: '5px',
                      marginBottom: '5px',
                      border: '1px solid rgba(0,255,0,0.5)',
                      borderRadius: '3px',
                    }}
                  >
                    <Box style={{ color: '#66ff66', fontWeight: 'bold' }}>
                      ✅ INFO
                    </Box>
                    <Box>All systems operational</Box>
                    <Box style={{ fontSize: '7px', opacity: '0.7' }}>
                      No recent alerts
                    </Box>
                  </Box>
                )}
              </Box>
            </Box>
          </Box>

          {/* Hume Meter */}
          <Box style={{ marginBottom: '20px' }}>
            <Box style={{ marginBottom: '10px', fontWeight: 'bold' }}>
              HUME METER
            </Box>
            <Flex align="flex-end" style={{ height: '40px' }}>
              {Array(20)
                .fill(0)
                .map((_, i) => (
                  <Box
                    key={i}
                    style={{
                      width: '3px',
                      height: `${Math.random() * 30 + 10}px`,
                      background: '#ffffff',
                      margin: '0 1px',
                      opacity: 0.8,
                    }}
                  />
                ))}
            </Flex>
          </Box>

          {/* Threat Detection */}
          <Box style={{ marginBottom: '20px' }}>
            <Box style={{ marginBottom: '10px', fontWeight: 'bold' }}>
              THREAT DETECTION
            </Box>
            <Flex align="center" style={{ marginBottom: '10px' }}>
              <Box
                style={{
                  width: '60px',
                  height: '60px',
                  border: '2px solid #ffffff',
                  borderRadius: '50%',
                  position: 'relative',
                  marginRight: '15px',
                }}
              >
                <Box
                  style={{
                    position: 'absolute',
                    top: '50%',
                    left: '50%',
                    width: '2px',
                    height: '25px',
                    background: '#ffffff',
                    transform: 'translate(-50%, -50%) rotate(45deg)',
                    transformOrigin: 'center',
                    animation: 'rotate 2s linear infinite',
                  }}
                />
              </Box>
              <Box>
                <Box>SYSTEM.STATUS</Box>
                <Box>CRITICAL.EVENT</Box>
                <Box>ANOMALY.DETECTED</Box>
              </Box>
            </Flex>
            <Box style={{ marginBottom: '10px' }}>
              <Box style={{ marginBottom: '5px' }}>HKG</Box>
              <Box
                style={{
                  width: '100%',
                  height: '20px',
                  background:
                    'linear-gradient(90deg, #ffffff 0%, #ffffff 30%, transparent 30%, transparent 100%)',
                  border: '1px solid rgba(255,255,255,0.3)',
                }}
              />
            </Box>
          </Box>

          {/* Antimemetic Interface */}
          <Box style={{ marginBottom: '20px' }}>
            <Box>ANTIMEMETIC INTERFACE...</Box>
            <Box>SCAN COMPLETE</Box>
            <Box>DEF MODE OFF</Box>
          </Box>

          {/* Displaying File */}
          <Box style={{ marginBottom: '20px' }}>
            <Box>DISPLAYING FILE</Box>
            <Box>VISIT COUNT / 86723</Box>
          </Box>

          {/* Event Log */}
          <Box>
            <Box style={{ marginBottom: '10px', fontWeight: 'bold' }}>
              EVENT LOG
            </Box>
            <Box style={{ fontSize: '10px', lineHeight: '1.4' }}>
              <Box>◆ 16:46 - ACCESSED DOCUMENT</Box>
              <Box>◆ 16:46 - EXECUTED: ACCESS</Box>
              <Box>◆ 16:45 - EXECUTED: ACCESS</Box>
              <Box>◆ 16:44 - EXECUTED: HELP</Box>
              <Box>◆ 16:44 - EXECUTED: LOGIN</Box>
              <Box>◆ 16:32 - ALL SYSTEMS OPERATIONAL</Box>
              <Box>◆ 16:32 - LOADING DATABASE.</Box>
              <Box>◆ 16:32 - LOADING SITE OVERVIEW.</Box>
              <Box>◆ 16:32 - SETTING UP EVENT.</Box>
              <Box>◆ 16:32 - LOADING ADDITIONAL...</Box>
            </Box>
          </Box>

          {/* Scroll indicator */}
          <Box
            style={{
              position: 'absolute',
              bottom: '20px',
              right: '20px',
              width: '8px',
              height: '60px',
              background: 'rgba(255,255,255,0.3)',
              borderRadius: '4px',
            }}
          >
            <Box
              style={{
                position: 'absolute',
                top: '10px',
                right: '0',
                fontSize: '10px',
                transform: 'rotate(90deg)',
              }}
            >
              78
            </Box>
          </Box>
        </>
      )}
    </Box>
  );

  return (
    <Window
      width={1200}
      height={800}
      theme="scp_terminal"
      style={{
        background: '#000000',
        fontFamily: 'monospace',
        fontSize: '14px',
        color: '#ffffff',
        margin: '0',
        padding: '0',
        overflow: 'hidden',
      }}
    >
      <Window.Content
        style={{
          background: 'transparent',
          padding: '0',
          fontFamily: 'monospace',
          position: 'relative',
          width: '100%',
          height: '100%',
          overflow: 'hidden',
        }}
      >
        <GridBackground />
        <WatermarkLogo />
        <Box
          style={{
            position: 'absolute',
            top: '0',
            left: '0',
            right: '0',
            bottom: '0',
            overflow: 'auto',
            zIndex: 5,
          }}
        >
          {(() => {
            console.log(
              'Rendering main interface, activeTab:',
              activeTab,
              'type:',
              typeof activeTab,
            );

            if (activeTab === 'desktop') return <DesktopInterface />;
            if (activeTab === 'terminal') return <TerminalInterface />;
            if (activeTab === 'facility') {
              return (
                <FacilityInterface
                  facilityActiveTab={facilityActiveTab}
                  setFacilityActiveTab={setFacilityActiveTab}
                />
              );
            }
            if (activeTab === 'scp') {
              return (
                <SCPInterface
                  scpActiveTab={scpActiveTab}
                  setScpActiveTab={setScpActiveTab}
                />
              );
            }
            if (activeTab === 'technology') {
              return (
                <TechnologyInterface
                  techActiveTab={techActiveTab}
                  setTechActiveTab={setTechActiveTab}
                />
              );
            }
            if (activeTab === 'medical') {
              return (
                <MedicalInterface
                  medicalActiveTab={medicalActiveTab}
                  setMedicalActiveTab={setMedicalActiveTab}
                />
              );
            }
            if (activeTab === 'security') {
              return (
                <SecurityInterface
                  securityActiveTab={securityActiveTab}
                  setSecurityActiveTab={setSecurityActiveTab}
                />
              );
            }
            if (activeTab === 'research') {
              return (
                <ResearchInterface
                  researchActiveTab={researchActiveTab}
                  setResearchActiveTab={setResearchActiveTab}
                />
              );
            }
            if (activeTab === 'personnel') {
              return (
                <PersonnelInterface
                  personnelActiveTab={personnelActiveTab}
                  setPersonnelActiveTab={setPersonnelActiveTab}
                />
              );
            }
            if (activeTab === 'players') {
              return (
                <PlayerInterface
                  playerActiveTab={playerActiveTab}
                  setPlayerActiveTab={setPlayerActiveTab}
                />
              );
            }

            if (activeTab === 'infrastructure') {
              return (
                <InfrastructureInterface
                  infrastructureActiveTab={infrastructureActiveTab}
                  setInfrastructureActiveTab={setInfrastructureActiveTab}
                />
              );
            }
            if (activeTab === 'analytics') {
              return (
                <AnalyticsInterface
                  analyticsActiveTab={analyticsActiveTab}
                  setAnalyticsActiveTab={setAnalyticsActiveTab}
                />
              );
            }
            if (activeTab === 'budget') {
              return (
                <BudgetInterface
                  budgetModal={budgetModal}
                  setBudgetModal={setBudgetModal}
                  budgetRequestModal={budgetRequestModal}
                  setBudgetRequestModal={setBudgetRequestModal}
                  budgetTransferModal={budgetTransferModal}
                  setBudgetTransferModal={setBudgetTransferModal}
                  budgetReportModal={budgetReportModal}
                  setBudgetReportModal={setBudgetReportModal}
                  budgetFormData={budgetFormData}
                  setBudgetFormData={setBudgetFormData}
                  budgetRequestData={budgetRequestData}
                  setBudgetRequestData={setBudgetRequestData}
                  budgetTransferData={budgetTransferData}
                  setBudgetTransferData={setBudgetTransferData}
                />
              );
            }

            return (
              <Box style={{ color: 'red', fontSize: '16px', padding: '20px' }}>
                No interface found for tab: &quot;{activeTab}&quot; (type:{' '}
                {typeof activeTab})
                <br />
                Available tabs: terminal, facility, scp, technology, medical,
                security, research, personnel, players, infrastructure,
                analytics, budget
              </Box>
            );
          })()}
        </Box>
        {activeTab !== 'desktop' && <SidePanel />}

        {/* Research Modal - Global Access */}
        {researchModalOpen && (
          <Box
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              background: 'rgba(0,0,0,0.85)',
              zIndex: 1000,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              backdropFilter: 'blur(5px)',
            }}
            onClick={() => setResearchModalOpen(false)}
          >
            <Box
              style={{
                background:
                  'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)',
                border: '2px solid rgba(255,255,255,0.3)',
                borderRadius: '15px',
                padding: '30px',
                width: '90vw',
                maxWidth: '1200px',
                maxHeight: '90vh',
                overflow: 'auto',
                position: 'relative',
                boxShadow: '0 20px 40px rgba(0,0,0,0.5)',
              }}
              onClick={(e) => e.stopPropagation()}
            >
              {/* Modal Header */}
              <Box
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  marginBottom: '25px',
                  borderBottom: '2px solid rgba(255,255,255,0.2)',
                  paddingBottom: '15px',
                }}
              >
                <Box
                  style={{
                    fontSize: '28px',
                    fontWeight: 'bold',
                    color: '#66ffff',
                  }}
                >
                  🔬 NEW RESEARCH PROJECT CREATION
                </Box>
                <Box
                  style={{
                    cursor: 'pointer',
                    fontSize: '24px',
                    opacity: 0.7,
                    transition: 'opacity 0.2s ease',
                    padding: '5px',
                    borderRadius: '5px',
                  }}
                  onClick={() => setResearchModalOpen(false)}
                  onMouseEnter={(e) => (e.target.style.opacity = '1')}
                  onMouseLeave={(e) => (e.target.style.opacity = '0.7')}
                >
                  ✕
                </Box>
              </Box>

              {/* Form Content */}
              <Box
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '25px',
                }}
              >
                {/* Basic Information Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    📋 BASIC INFORMATION
                  </Box>
                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Project Title *
                        </Box>
                        <input
                          type="text"
                          value={researchFormData.title}
                          onChange={(e) =>
                            setResearchFormData({
                              ...researchFormData,
                              title: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                            transition: 'border-color 0.3s ease',
                          }}
                          placeholder="Enter project title..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Lead Researcher *
                        </Box>
                        <input
                          type="text"
                          value={researchFormData.lead_researcher}
                          onChange={(e) =>
                            setResearchFormData({
                              ...researchFormData,
                              lead_researcher: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="Enter researcher name..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>

                  <Box style={{ marginBottom: '15px' }}>
                    <Box
                      style={{
                        fontSize: '14px',
                        marginBottom: '8px',
                        opacity: 0.8,
                      }}
                    >
                      Project Description *
                    </Box>
                    <textarea
                      value={researchFormData.description}
                      onChange={(e) =>
                        setResearchFormData({
                          ...researchFormData,
                          description: e.target.value,
                        })
                      }
                      style={{
                        width: '100%',
                        height: '100px',
                        padding: '12px',
                        background: 'rgba(255,255,255,0.1)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        borderRadius: '6px',
                        color: '#ffffff',
                        fontSize: '14px',
                        resize: 'vertical',
                      }}
                      placeholder="Describe the research project, objectives, and expected outcomes..."
                    />
                  </Box>
                </Box>

                {/* Classification Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    🏷️ CLASSIFICATION & PRIORITY
                  </Box>
                  <Grid>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Research Category
                        </Box>
                        <select
                          value={researchFormData.category}
                          onChange={(e) =>
                            setResearchFormData({
                              ...researchFormData,
                              category: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="general">🔬 General Research</option>
                          <option value="scp">🔒 SCP Studies</option>
                          <option value="containment">🛡️ Containment</option>
                          <option value="medical">🏥 Medical Research</option>
                          <option value="technology">⚡ Technology</option>
                          <option value="psychology">🧠 Psychology</option>
                          <option value="physics">⚛️ Physics</option>
                          <option value="chemistry">🧪 Chemistry</option>
                          <option value="biology">🧬 Biology</option>
                          <option value="mathematics">📐 Mathematics</option>
                        </select>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Priority Level
                        </Box>
                        <select
                          value={researchFormData.priority}
                          onChange={(e) =>
                            setResearchFormData({
                              ...researchFormData,
                              priority: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="low">🟢 Low Priority</option>
                          <option value="medium">🟡 Medium Priority</option>
                          <option value="high">🟠 High Priority</option>
                          <option value="critical">🔴 Critical Priority</option>
                        </select>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Security Clearance
                        </Box>
                        <select
                          value={researchFormData.security_clearance}
                          onChange={(e) =>
                            setResearchFormData({
                              ...researchFormData,
                              security_clearance: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="level_1">🔓 Level 1 - Basic</option>
                          <option value="level_2">
                            🔒 Level 2 - Restricted
                          </option>
                          <option value="level_3">
                            🔐 Level 3 - Confidential
                          </option>
                          <option value="level_4">🔐 Level 4 - Secret</option>
                          <option value="level_5">
                            🔐 Level 5 - Top Secret
                          </option>
                        </select>
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Timeline & Resources Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    ⏰ TIMELINE & RESOURCES
                  </Box>
                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: '0.8',
                          }}
                        >
                          Project Timeline
                        </Box>
                        <input
                          type="text"
                          value={researchFormData.timeline}
                          onChange={(e) =>
                            setResearchFormData({
                              ...researchFormData,
                              timeline: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 6 months, 1 year, ongoing..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: '0.8',
                          }}
                        >
                          Budget Allocation
                        </Box>
                        <input
                          type="text"
                          value={researchFormData.budget}
                          onChange={(e) =>
                            setResearchFormData({
                              ...researchFormData,
                              budget: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., $50,000, 100,000 credits..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>

                  <Box style={{ marginBottom: '15px' }}>
                    <Box
                      style={{
                        fontSize: '14px',
                        marginBottom: '8px',
                        opacity: '0.8',
                      }}
                    >
                      Funding Source
                    </Box>
                    <input
                      type="text"
                      value={researchFormData.funding_source}
                      onChange={(e) =>
                        setResearchFormData({
                          ...researchFormData,
                          funding_source: e.target.value,
                        })
                      }
                      style={{
                        width: '100%',
                        padding: '12px',
                        background: 'rgba(255,255,255,0.1)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        borderRadius: '6px',
                        color: '#ffffff',
                        fontSize: '14px',
                      }}
                      placeholder="e.g., Foundation Budget, External Grant, Special Allocation..."
                    />
                  </Box>
                </Box>

                {/* Research Details Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    🔬 RESEARCH DETAILS
                  </Box>
                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: '0.8',
                          }}
                        >
                          Research Objectives
                        </Box>
                        <textarea
                          value={researchFormData.objectives}
                          onChange={(e) =>
                            setResearchFormData({
                              ...researchFormData,
                              objectives: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            height: '100px',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                            resize: 'vertical',
                          }}
                          placeholder="List specific research objectives..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: '0.8',
                          }}
                        >
                          Methodology
                        </Box>
                        <textarea
                          value={researchFormData.methodology}
                          onChange={(e) =>
                            setResearchFormData({
                              ...researchFormData,
                              methodology: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            height: '100px',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                            resize: 'vertical',
                          }}
                          placeholder="Describe research methodology..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>

                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: '0.8',
                          }}
                        >
                          Expected Outcomes
                        </Box>
                        <textarea
                          value={researchFormData.expected_outcomes}
                          onChange={(e) =>
                            setResearchFormData({
                              ...researchFormData,
                              expected_outcomes: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            height: '80px',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                            resize: 'vertical',
                          }}
                          placeholder="Describe expected outcomes..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: '0.8',
                          }}
                        >
                          Potential Risks
                        </Box>
                        <textarea
                          value={researchFormData.risks}
                          onChange={(e) =>
                            setResearchFormData({
                              ...researchFormData,
                              risks: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            height: '80px',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                            resize: 'vertical',
                          }}
                          placeholder="Describe potential risks and mitigation..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Safety & Compliance Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    🛡️ SAFETY & COMPLIANCE
                  </Box>
                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: '0.8',
                          }}
                        >
                          Containment Requirements
                        </Box>
                        <textarea
                          value={researchFormData.containment_requirements}
                          onChange={(e) =>
                            setResearchFormData({
                              ...researchFormData,
                              containment_requirements: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            height: '80px',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                            resize: 'vertical',
                          }}
                          placeholder="Describe containment requirements..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: '0.8',
                          }}
                        >
                          Safety Protocols
                        </Box>
                        <textarea
                          value={researchFormData.safety_protocols}
                          onChange={(e) =>
                            setResearchFormData({
                              ...researchFormData,
                              safety_protocols: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            height: '80px',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                            resize: 'vertical',
                          }}
                          placeholder="Describe safety protocols..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>

                  <Box style={{ marginBottom: '15px' }}>
                    <Box
                      style={{
                        display: 'flex',
                        alignItems: 'center',
                        gap: '10px',
                      }}
                    >
                      <input
                        type="checkbox"
                        checked={researchFormData.ethical_approval}
                        onChange={(e) =>
                          setResearchFormData({
                            ...researchFormData,
                            ethical_approval: e.target.checked,
                          })
                        }
                        style={{
                          width: '18px',
                          height: '18px',
                          accentColor: '#66ffff',
                        }}
                      />
                      <Box style={{ fontSize: '14px', opacity: '0.8' }}>
                        Ethical Approval Required
                      </Box>
                    </Box>
                  </Box>
                </Box>

                {/* Action Buttons */}
                <Box
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    marginTop: '20px',
                    borderTop: '2px solid rgba(255,255,255,0.2)',
                    paddingTop: '20px',
                  }}
                >
                  <Box style={{ fontSize: '14px', opacity: '0.7' }}>
                    * Required fields must be completed
                  </Box>
                  <Box style={{ display: 'flex', gap: '15px' }}>
                    <EnhancedButton
                      onClick={() => setResearchModalOpen(false)}
                      color="default"
                      tooltip="Cancel and close form"
                    >
                      ✕ Cancel
                    </EnhancedButton>
                    <EnhancedButton
                      color="good"
                      onClick={() => {
                        // Validate required fields
                        if (
                          !researchFormData.title ||
                          !researchFormData.description ||
                          !researchFormData.lead_researcher
                        ) {
                          addNotification(
                            'Validation Error',
                            'Please complete all required fields',
                            'error',
                          );
                          return;
                        }

                        // Submit to backend
                        act('research_add_project', {
                          project_data: researchFormData,
                        });

                        // Show success notification
                        addNotification(
                          'Success',
                          'Research project created successfully',
                          'success',
                        );

                        // Reset form and close modal
                        setResearchFormData({
                          title: '',
                          description: '',
                          category: 'general',
                          priority: 'medium',
                          lead_researcher: '',
                          budget: '',
                          timeline: '',
                          objectives: '',
                          methodology: '',
                          expected_outcomes: '',
                          risks: '',
                          approvals: [],
                          status: 'pending',
                          progress: 0,
                          start_date: '',
                          end_date: '',
                          team_members: [],
                          equipment_needed: [],
                          funding_source: '',
                          security_clearance: 'level_1',
                          containment_requirements: '',
                          ethical_approval: false,
                          safety_protocols: '',
                        });
                        setResearchModalOpen(false);
                      }}
                      tooltip="Create research project"
                    >
                      📋 Create Research Project
                    </EnhancedButton>
                  </Box>
                </Box>
              </Box>
            </Box>
          </Box>
        )}

        {/* SCP Modal - Global Access */}
        {scpModalOpen && (
          <Box
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              background: 'rgba(0,0,0,0.85)',
              zIndex: 1000,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              backdropFilter: 'blur(5px)',
            }}
            onClick={() => setScpModalOpen(false)}
          >
            <Box
              style={{
                background:
                  'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)',
                border: '2px solid rgba(255,255,255,0.3)',
                borderRadius: '15px',
                padding: '30px',
                width: '90vw',
                maxWidth: '1200px',
                maxHeight: '90vh',
                overflow: 'auto',
                position: 'relative',
                boxShadow: '0 20px 40px rgba(0,0,0,0.5)',
              }}
              onClick={(e) => e.stopPropagation()}
            >
              {/* Modal Header */}
              <Box
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  marginBottom: '25px',
                  borderBottom: '2px solid rgba(255,255,255,0.2)',
                  paddingBottom: '15px',
                }}
              >
                <Box
                  style={{
                    fontSize: '28px',
                    fontWeight: 'bold',
                    color: '#66ffff',
                  }}
                >
                  🔒 NEW SCP INSTANCE CREATION
                </Box>
                <Box
                  style={{
                    cursor: 'pointer',
                    fontSize: '24px',
                    opacity: 0.7,
                    transition: 'opacity 0.2s ease',
                    padding: '5px',
                    borderRadius: '5px',
                  }}
                  onClick={() => setScpModalOpen(false)}
                  onMouseEnter={(e) => (e.target.style.opacity = '1')}
                  onMouseLeave={(e) => (e.target.style.opacity = '0.7')}
                >
                  ✕
                </Box>
              </Box>

              {/* Form Content */}
              <Box
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '25px',
                }}
              >
                {/* Basic Information Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    🔒 BASIC INFORMATION
                  </Box>
                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          SCP Designation *
                        </Box>
                        <input
                          type="text"
                          value={scpFormData.designation}
                          onChange={(e) =>
                            setScpFormData({
                              ...scpFormData,
                              designation: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., SCP-173, SCP-096..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Object Name
                        </Box>
                        <input
                          type="text"
                          value={scpFormData.name}
                          onChange={(e) =>
                            setScpFormData({
                              ...scpFormData,
                              name: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., The Sculpture, The Shy Guy..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>

                  <Grid>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Object Class *
                        </Box>
                        <select
                          value={scpFormData.object_class}
                          onChange={(e) =>
                            setScpFormData({
                              ...scpFormData,
                              object_class: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="safe">🟢 Safe</option>
                          <option value="euclid">🟡 Euclid</option>
                          <option value="keter">🔴 Keter</option>
                          <option value="thaumiel">🔵 Thaumiel</option>
                          <option value="neutralized">⚪ Neutralized</option>
                          <option value="pending">🟠 Pending</option>
                        </select>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Threat Level
                        </Box>
                        <select
                          value={scpFormData.threat_level}
                          onChange={(e) =>
                            setScpFormData({
                              ...scpFormData,
                              threat_level: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="green">🟢 Green</option>
                          <option value="yellow">🟡 Yellow</option>
                          <option value="orange">🟠 Orange</option>
                          <option value="red">🔴 Red</option>
                          <option value="black">⚫ Black</option>
                        </select>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Current Status
                        </Box>
                        <select
                          value={scpFormData.current_status}
                          onChange={(e) =>
                            setScpFormData({
                              ...scpFormData,
                              current_status: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="contained">🔒 Contained</option>
                          <option value="breach">🚨 Breach</option>
                          <option value="testing">🧪 Testing</option>
                          <option value="recovery">🔄 Recovery</option>
                          <option value="terminated">💀 Terminated</option>
                          <option value="pending">⏳ Pending</option>
                        </select>
                      </Box>
                    </Grid.Column>
                  </Grid>

                  <Box style={{ marginBottom: '15px' }}>
                    <Box
                      style={{
                        fontSize: '14px',
                        marginBottom: '8px',
                        opacity: 0.8,
                      }}
                    >
                      Description *
                    </Box>
                    <textarea
                      value={scpFormData.description}
                      onChange={(e) =>
                        setScpFormData({
                          ...scpFormData,
                          description: e.target.value,
                        })
                      }
                      style={{
                        width: '100%',
                        height: '120px',
                        padding: '12px',
                        background: 'rgba(255,255,255,0.1)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        borderRadius: '6px',
                        color: '#ffffff',
                        fontSize: '14px',
                        resize: 'vertical',
                      }}
                      placeholder="Describe the SCP's appearance, behavior, and anomalous properties..."
                    />
                  </Box>
                </Box>

                {/* Containment Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    🛡️ CONTAINMENT PROCEDURES
                  </Box>
                  <Box style={{ marginBottom: '15px' }}>
                    <Box
                      style={{
                        fontSize: '14px',
                        marginBottom: '8px',
                        opacity: 0.8,
                      }}
                    >
                      Standard Containment Procedures *
                    </Box>
                    <textarea
                      value={scpFormData.containment_procedures}
                      onChange={(e) =>
                        setScpFormData({
                          ...scpFormData,
                          containment_procedures: e.target.value,
                        })
                      }
                      style={{
                        width: '100%',
                        height: '100px',
                        padding: '12px',
                        background: 'rgba(255,255,255,0.1)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        borderRadius: '6px',
                        color: '#ffffff',
                        fontSize: '14px',
                        resize: 'vertical',
                      }}
                      placeholder="Describe standard containment procedures..."
                    />
                  </Box>

                  <Box style={{ marginBottom: '15px' }}>
                    <Box
                      style={{
                        fontSize: '14px',
                        marginBottom: '8px',
                        opacity: 0.8,
                      }}
                    >
                      Special Containment Procedures
                    </Box>
                    <textarea
                      value={scpFormData.special_containment_procedures}
                      onChange={(e) =>
                        setScpFormData({
                          ...scpFormData,
                          special_containment_procedures: e.target.value,
                        })
                      }
                      style={{
                        width: '100%',
                        height: '100px',
                        padding: '12px',
                        background: 'rgba(255,255,255,0.1)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        borderRadius: '6px',
                        color: '#ffffff',
                        fontSize: '14px',
                        resize: 'vertical',
                      }}
                      placeholder="Describe special containment procedures..."
                    />
                  </Box>

                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Containment Location
                        </Box>
                        <input
                          type="text"
                          value={scpFormData.location}
                          onChange={(e) =>
                            setScpFormData({
                              ...scpFormData,
                              location: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., Site-19, Chamber-173..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Containment Cost
                        </Box>
                        <input
                          type="text"
                          value={scpFormData.containment_cost}
                          onChange={(e) =>
                            setScpFormData({
                              ...scpFormData,
                              containment_cost: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., $50,000/month, 100,000 credits..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Discovery & History Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    📅 DISCOVERY & HISTORY
                  </Box>
                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Discovery Date
                        </Box>
                        <input
                          type="text"
                          value={scpFormData.discovery_date}
                          onChange={(e) =>
                            setScpFormData({
                              ...scpFormData,
                              discovery_date: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 1993-06-23, 2007..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Discovery Location
                        </Box>
                        <input
                          type="text"
                          value={scpFormData.discovery_location}
                          onChange={(e) =>
                            setScpFormData({
                              ...scpFormData,
                              discovery_location: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., Rome, Italy, Museum of Modern Art..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>

                  <Box style={{ marginBottom: '15px' }}>
                    <Box
                      style={{
                        fontSize: '14px',
                        marginBottom: '8px',
                        opacity: 0.8,
                      }}
                    >
                      Recovery Notes
                    </Box>
                    <textarea
                      value={scpFormData.recovery_notes}
                      onChange={(e) =>
                        setScpFormData({
                          ...scpFormData,
                          recovery_notes: e.target.value,
                        })
                      }
                      style={{
                        width: '100%',
                        height: '80px',
                        padding: '12px',
                        background: 'rgba(255,255,255,0.1)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        borderRadius: '6px',
                        color: '#ffffff',
                        fontSize: '14px',
                        resize: 'vertical',
                      }}
                      placeholder="Describe the recovery operation and initial containment..."
                    />
                  </Box>
                </Box>

                {/* Action Buttons */}
                <Box
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    marginTop: '20px',
                    borderTop: '2px solid rgba(255,255,255,0.2)',
                    paddingTop: '20px',
                  }}
                >
                  <Box style={{ fontSize: '14px', opacity: '0.7' }}>
                    * Required fields must be completed
                  </Box>
                  <Box style={{ display: 'flex', gap: '15px' }}>
                    <EnhancedButton
                      onClick={() => setScpModalOpen(false)}
                      color="default"
                      tooltip="Cancel and close form"
                    >
                      ✕ Cancel
                    </EnhancedButton>
                    <EnhancedButton
                      color="good"
                      onClick={() => {
                        // Validate required fields
                        if (
                          !scpFormData.designation ||
                          !scpFormData.description ||
                          !scpFormData.containment_procedures
                        ) {
                          addNotification(
                            'Validation Error',
                            'Please complete all required fields',
                            'error',
                          );
                          return;
                        }

                        // Submit to backend
                        act('scp_add_instance', {
                          scp_data: scpFormData,
                        });

                        // Show success notification
                        addNotification(
                          'Success',
                          'SCP instance created successfully',
                          'success',
                        );

                        // Reset form and close modal
                        setScpFormData({
                          designation: '',
                          name: '',
                          object_class: 'safe',
                          threat_level: 'green',
                          description: '',
                          containment_procedures: '',
                          special_containment_procedures: '',
                          description_2: '',
                          addenda: '',
                          incident_reports: [],
                          testing_logs: [],
                          personnel_assignments: [],
                          location: '',
                          discovery_date: '',
                          discovery_location: '',
                          original_containment: '',
                          current_status: 'contained',
                          containment_breaches: 0,
                          last_incident: '',
                          research_clearance: 'level_1',
                          testing_authorized: false,
                          cross_testing: [],
                          related_scps: [],
                          anomalous_properties: '',
                          recovery_notes: '',
                          classification_notes: '',
                          security_clearance: 'level_1',
                          containment_cost: '',
                          maintenance_schedule: '',
                          monitoring_equipment: [],
                          emergency_protocols: '',
                          termination_attempts: [],
                          containment_effectiveness: 100,
                          risk_assessment: '',
                          personnel_requirements: '',
                          facility_requirements: '',
                          budget_allocation: '',
                          research_priorities: [],
                          containment_upgrades: [],
                          incident_history: [],
                          testing_protocols: '',
                          cross_references: [],
                          classification_review_date: '',
                          containment_review_date: '',
                          security_audit_date: '',
                          last_containment_test: '',
                          next_containment_test: '',
                          containment_rating: 'stable',
                          threat_assessment: 'low',
                          containment_priority: 'standard',
                          research_priority: 'standard',
                          security_priority: 'standard',
                          maintenance_priority: 'standard',
                          testing_priority: 'standard',
                          monitoring_priority: 'standard',
                          emergency_priority: 'standard',
                          termination_priority: 'none',
                          classification_priority: 'standard',
                          containment_priority_level: 'standard',
                          research_priority_level: 'standard',
                          security_priority_level: 'standard',
                          maintenance_priority_level: 'standard',
                          testing_priority_level: 'standard',
                          monitoring_priority_level: 'standard',
                          emergency_priority_level: 'standard',
                          termination_priority_level: 'none',
                          classification_priority_level: 'standard',
                        });
                        setScpModalOpen(false);
                      }}
                      tooltip="Create SCP instance"
                    >
                      🔒 Create SCP Instance
                    </EnhancedButton>
                  </Box>
                </Box>
              </Box>
            </Box>
          </Box>
        )}

        {/* Medical Modal - Global Access */}
        {medicalModalOpen && (
          <Box
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              background: 'rgba(0,0,0,0.85)',
              zIndex: 1000,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              backdropFilter: 'blur(5px)',
            }}
            onClick={() => setMedicalModalOpen(false)}
          >
            <Box
              style={{
                background:
                  'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)',
                border: '2px solid rgba(255,255,255,0.3)',
                borderRadius: '15px',
                padding: '30px',
                width: '90vw',
                maxWidth: '1200px',
                maxHeight: '90vh',
                overflow: 'auto',
                position: 'relative',
                boxShadow: '0 20px 40px rgba(0,0,0,0.5)',
              }}
              onClick={(e) => e.stopPropagation()}
            >
              {/* Modal Header */}
              <Box
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  marginBottom: '25px',
                  borderBottom: '2px solid rgba(255,255,255,0.2)',
                  paddingBottom: '15px',
                }}
              >
                <Box
                  style={{
                    fontSize: '28px',
                    fontWeight: 'bold',
                    color: '#66ffff',
                  }}
                >
                  👤 NEW PATIENT REGISTRATION
                </Box>
                <Box
                  style={{
                    cursor: 'pointer',
                    fontSize: '24px',
                    opacity: 0.7,
                    transition: 'opacity 0.2s ease',
                    padding: '5px',
                    borderRadius: '5px',
                  }}
                  onClick={() => setMedicalModalOpen(false)}
                  onMouseEnter={(e) => (e.target.style.opacity = '1')}
                  onMouseLeave={(e) => (e.target.style.opacity = '0.7')}
                >
                  ✕
                </Box>
              </Box>

              {/* Form Content */}
              <Box
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '25px',
                }}
              >
                {/* Patient Information Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    👤 PATIENT INFORMATION
                  </Box>
                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Patient ID *
                        </Box>
                        <input
                          type="text"
                          value={medicalFormData.patient_id}
                          onChange={(e) =>
                            setMedicalFormData({
                              ...medicalFormData,
                              patient_id: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., P-2024-001, MED-001..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Patient Name *
                        </Box>
                        <input
                          type="text"
                          value={medicalFormData.patient_name}
                          onChange={(e) =>
                            setMedicalFormData({
                              ...medicalFormData,
                              patient_name: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="Full name..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>

                  <Grid>
                    <Grid.Column size={3}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Age
                        </Box>
                        <input
                          type="number"
                          value={medicalFormData.age}
                          onChange={(e) =>
                            setMedicalFormData({
                              ...medicalFormData,
                              age: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="Age..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Gender
                        </Box>
                        <select
                          value={medicalFormData.gender}
                          onChange={(e) =>
                            setMedicalFormData({
                              ...medicalFormData,
                              gender: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="">Select...</option>
                          <option value="male">Male</option>
                          <option value="female">Female</option>
                          <option value="other">Other</option>
                          <option value="prefer_not_to_say">
                            Prefer not to say
                          </option>
                        </select>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Blood Type
                        </Box>
                        <select
                          value={medicalFormData.blood_type}
                          onChange={(e) =>
                            setMedicalFormData({
                              ...medicalFormData,
                              blood_type: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="">Select...</option>
                          <option value="A+">A+</option>
                          <option value="A-">A-</option>
                          <option value="B+">B+</option>
                          <option value="B-">B-</option>
                          <option value="AB+">AB+</option>
                          <option value="AB-">AB-</option>
                          <option value="O+">O+</option>
                          <option value="O-">O-</option>
                        </select>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Room Number
                        </Box>
                        <input
                          type="text"
                          value={medicalFormData.room_number}
                          onChange={(e) =>
                            setMedicalFormData({
                              ...medicalFormData,
                              room_number: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 101, ICU-1..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Medical Details Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    🏥 MEDICAL DETAILS
                  </Box>
                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Current Condition *
                        </Box>
                        <textarea
                          value={medicalFormData.current_condition}
                          onChange={(e) =>
                            setMedicalFormData({
                              ...medicalFormData,
                              current_condition: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            height: '80px',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                            resize: 'vertical',
                          }}
                          placeholder="Describe current medical condition..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Symptoms
                        </Box>
                        <textarea
                          value={medicalFormData.symptoms}
                          onChange={(e) =>
                            setMedicalFormData({
                              ...medicalFormData,
                              symptoms: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            height: '80px',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                            resize: 'vertical',
                          }}
                          placeholder="List symptoms..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>

                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Diagnosis
                        </Box>
                        <textarea
                          value={medicalFormData.diagnosis}
                          onChange={(e) =>
                            setMedicalFormData({
                              ...medicalFormData,
                              diagnosis: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            height: '80px',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                            resize: 'vertical',
                          }}
                          placeholder="Medical diagnosis..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Treatment Plan
                        </Box>
                        <textarea
                          value={medicalFormData.treatment_plan}
                          onChange={(e) =>
                            setMedicalFormData({
                              ...medicalFormData,
                              treatment_plan: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            height: '80px',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                            resize: 'vertical',
                          }}
                          placeholder="Treatment plan..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Vital Signs Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    💓 VITAL SIGNS
                  </Box>
                  <Grid>
                    <Grid.Column size={2}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Temperature
                        </Box>
                        <input
                          type="text"
                          value={medicalFormData.vital_signs.temperature}
                          onChange={(e) =>
                            setMedicalFormData({
                              ...medicalFormData,
                              vital_signs: {
                                ...medicalFormData.vital_signs,
                                temperature: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="°C"
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={2}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Blood Pressure
                        </Box>
                        <input
                          type="text"
                          value={medicalFormData.vital_signs.blood_pressure}
                          onChange={(e) =>
                            setMedicalFormData({
                              ...medicalFormData,
                              vital_signs: {
                                ...medicalFormData.vital_signs,
                                blood_pressure: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="mmHg"
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={2}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Heart Rate
                        </Box>
                        <input
                          type="text"
                          value={medicalFormData.vital_signs.heart_rate}
                          onChange={(e) =>
                            setMedicalFormData({
                              ...medicalFormData,
                              vital_signs: {
                                ...medicalFormData.vital_signs,
                                heart_rate: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="bpm"
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={2}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Respiratory Rate
                        </Box>
                        <input
                          type="text"
                          value={medicalFormData.vital_signs.respiratory_rate}
                          onChange={(e) =>
                            setMedicalFormData({
                              ...medicalFormData,
                              vital_signs: {
                                ...medicalFormData.vital_signs,
                                respiratory_rate: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="rpm"
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={2}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          O2 Saturation
                        </Box>
                        <input
                          type="text"
                          value={medicalFormData.vital_signs.oxygen_saturation}
                          onChange={(e) =>
                            setMedicalFormData({
                              ...medicalFormData,
                              vital_signs: {
                                ...medicalFormData.vital_signs,
                                oxygen_saturation: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="%"
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Action Buttons */}
                <Box
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    marginTop: '20px',
                    borderTop: '2px solid rgba(255,255,255,0.2)',
                    paddingTop: '20px',
                  }}
                >
                  <Box style={{ fontSize: '14px', opacity: '0.7' }}>
                    * Required fields must be completed
                  </Box>
                  <Box style={{ display: 'flex', gap: '15px' }}>
                    <EnhancedButton
                      onClick={() => setMedicalModalOpen(false)}
                      color="default"
                      tooltip="Cancel and close form"
                    >
                      ✕ Cancel
                    </EnhancedButton>
                    <EnhancedButton
                      color="good"
                      onClick={() => {
                        // Validate required fields
                        if (
                          !medicalFormData.patient_id ||
                          !medicalFormData.patient_name ||
                          !medicalFormData.current_condition
                        ) {
                          addNotification(
                            'Validation Error',
                            'Please complete all required fields',
                            'error',
                          );
                          return;
                        }

                        // Submit to backend
                        act('medical_add_patient', {
                          patient_data: medicalFormData,
                        });

                        // Show success notification
                        addNotification(
                          'Success',
                          'Patient registered successfully',
                          'success',
                        );

                        // Reset form and close modal
                        setMedicalFormData({
                          patient_id: '',
                          patient_name: '',
                          age: '',
                          gender: '',
                          blood_type: '',
                          medical_history: '',
                          current_condition: '',
                          symptoms: '',
                          diagnosis: '',
                          treatment_plan: '',
                          medications: [],
                          allergies: [],
                          vital_signs: {
                            temperature: '',
                            blood_pressure: '',
                            heart_rate: '',
                            respiratory_rate: '',
                            oxygen_saturation: '',
                          },
                          lab_results: [],
                          imaging_results: [],
                          procedures: [],
                          notes: '',
                          attending_physician: '',
                          department: '',
                          admission_date: '',
                          discharge_date: '',
                          room_number: '',
                          emergency_contact: '',
                          insurance_info: '',
                          next_of_kin: '',
                          special_instructions: '',
                          quarantine_status: false,
                          isolation_level: 'none',
                          infectious_disease: false,
                          disease_type: '',
                          containment_required: false,
                          containment_level: 'none',
                          security_clearance: 'level_1',
                          research_subject: false,
                          research_protocol: '',
                          experimental_treatment: false,
                          treatment_consent: false,
                          family_consent: false,
                          legal_guardian: '',
                          power_of_attorney: '',
                          do_not_resuscitate: false,
                          living_will: false,
                          organ_donor: false,
                          autopsy_authorized: false,
                          research_authorized: false,
                          experimental_authorized: false,
                          testing_authorized: false,
                          monitoring_authorized: false,
                          isolation_authorized: false,
                          quarantine_authorized: false,
                          containment_authorized: false,
                          security_authorized: false,
                          research_priority: 'standard',
                          treatment_priority: 'standard',
                          monitoring_priority: 'standard',
                          security_priority: 'standard',
                          containment_priority: 'standard',
                          isolation_priority: 'standard',
                          quarantine_priority: 'standard',
                          testing_priority: 'standard',
                          autopsy_priority: 'none',
                          research_priority_level: 'standard',
                          treatment_priority_level: 'standard',
                          monitoring_priority_level: 'standard',
                          security_priority_level: 'standard',
                          containment_priority_level: 'standard',
                          isolation_priority_level: 'standard',
                          quarantine_priority_level: 'standard',
                          testing_priority_level: 'standard',
                          autopsy_priority_level: 'none',
                        });
                        setMedicalModalOpen(false);
                      }}
                      tooltip="Register patient"
                    >
                      👤 Register Patient
                    </EnhancedButton>
                  </Box>
                </Box>
              </Box>
            </Box>
          </Box>
        )}

        {/* Security Modal - Global Access */}
        {securityModalOpen && (
          <Box
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              background: 'rgba(0,0,0,0.85)',
              zIndex: 1000,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              backdropFilter: 'blur(5px)',
            }}
            onClick={() => setSecurityModalOpen(false)}
          >
            <Box
              style={{
                background:
                  'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)',
                border: '2px solid rgba(255,255,255,0.3)',
                borderRadius: '15px',
                padding: '30px',
                width: '90vw',
                maxWidth: '1200px',
                maxHeight: '90vh',
                overflow: 'auto',
                position: 'relative',
                boxShadow: '0 20px 40px rgba(0,0,0,0.5)',
              }}
              onClick={(e) => e.stopPropagation()}
            >
              {/* Modal Header */}
              <Box
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  marginBottom: '25px',
                  borderBottom: '2px solid rgba(255,255,255,0.2)',
                  paddingBottom: '15px',
                }}
              >
                <Box
                  style={{
                    fontSize: '28px',
                    fontWeight: 'bold',
                    color: '#66ffff',
                  }}
                >
                  🚨 SECURITY INCIDENT REPORT
                </Box>
                <Box
                  style={{
                    cursor: 'pointer',
                    fontSize: '24px',
                    opacity: 0.7,
                    transition: 'opacity 0.2s ease',
                    padding: '5px',
                    borderRadius: '5px',
                  }}
                  onClick={() => setSecurityModalOpen(false)}
                  onMouseEnter={(e) => (e.target.style.opacity = '1')}
                  onMouseLeave={(e) => (e.target.style.opacity = '0.7')}
                >
                  ✕
                </Box>
              </Box>

              {/* Form Content */}
              <Box
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '25px',
                }}
              >
                {/* Incident Information Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    🚨 INCIDENT INFORMATION
                  </Box>
                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Incident ID *
                        </Box>
                        <input
                          type="text"
                          value={securityFormData.incident_id}
                          onChange={(e) =>
                            setSecurityFormData({
                              ...securityFormData,
                              incident_id: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., INC-2024-001, SEC-001..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Incident Type *
                        </Box>
                        <select
                          value={securityFormData.incident_type}
                          onChange={(e) =>
                            setSecurityFormData({
                              ...securityFormData,
                              incident_type: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="breach">🔓 Containment Breach</option>
                          <option value="intrusion">
                            🚪 Security Intrusion
                          </option>
                          <option value="theft">🦹 Theft</option>
                          <option value="sabotage">💥 Sabotage</option>
                          <option value="espionage">🕵️ Espionage</option>
                          <option value="violence">⚔️ Violence</option>
                          <option value="accident">⚠️ Accident</option>
                          <option value="system_failure">
                            💻 System Failure
                          </option>
                          <option value="personnel_incident">
                            👥 Personnel Incident
                          </option>
                          <option value="other">❓ Other</option>
                        </select>
                      </Box>
                    </Grid.Column>
                  </Grid>

                  <Grid>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Severity Level *
                        </Box>
                        <select
                          value={securityFormData.severity}
                          onChange={(e) =>
                            setSecurityFormData({
                              ...securityFormData,
                              severity: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="low">🟢 Low</option>
                          <option value="medium">🟡 Medium</option>
                          <option value="high">🟠 High</option>
                          <option value="critical">🔴 Critical</option>
                          <option value="catastrophic">⚫ Catastrophic</option>
                        </select>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Threat Level
                        </Box>
                        <select
                          value={securityFormData.threat_level}
                          onChange={(e) =>
                            setSecurityFormData({
                              ...securityFormData,
                              threat_level: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="green">🟢 Green</option>
                          <option value="yellow">🟡 Yellow</option>
                          <option value="orange">🟠 Orange</option>
                          <option value="red">🔴 Red</option>
                          <option value="black">⚫ Black</option>
                        </select>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Containment Status
                        </Box>
                        <select
                          value={securityFormData.containment_status}
                          onChange={(e) =>
                            setSecurityFormData({
                              ...securityFormData,
                              containment_status: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="contained">🔒 Contained</option>
                          <option value="ongoing">🔄 Ongoing</option>
                          <option value="escalating">📈 Escalating</option>
                          <option value="resolved">✅ Resolved</option>
                          <option value="uncontained">🚨 Uncontained</option>
                        </select>
                      </Box>
                    </Grid.Column>
                  </Grid>

                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Location *
                        </Box>
                        <input
                          type="text"
                          value={securityFormData.location}
                          onChange={(e) =>
                            setSecurityFormData({
                              ...securityFormData,
                              location: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., Site-19, Sector-7, Chamber-173..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Date & Time *
                        </Box>
                        <input
                          type="text"
                          value={securityFormData.date_time}
                          onChange={(e) =>
                            setSecurityFormData({
                              ...securityFormData,
                              date_time: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 2024-01-15 14:30:00..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Incident Details Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    📋 INCIDENT DETAILS
                  </Box>
                  <Box style={{ marginBottom: '15px' }}>
                    <Box
                      style={{
                        fontSize: '14px',
                        marginBottom: '8px',
                        opacity: 0.8,
                      }}
                    >
                      Description *
                    </Box>
                    <textarea
                      value={securityFormData.description}
                      onChange={(e) =>
                        setSecurityFormData({
                          ...securityFormData,
                          description: e.target.value,
                        })
                      }
                      style={{
                        width: '100%',
                        height: '120px',
                        padding: '12px',
                        background: 'rgba(255,255,255,0.1)',
                        border: '1px solid rgba(255,255,255,0.3)',
                        borderRadius: '6px',
                        color: '#ffffff',
                        fontSize: '14px',
                        resize: 'vertical',
                      }}
                      placeholder="Provide detailed description of the incident, including what happened, when, where, and how..."
                    />
                  </Box>
                </Box>

                {/* Casualties Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    💀 CASUALTIES & DAMAGE
                  </Box>
                  <Grid>
                    <Grid.Column size={3}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Fatalities
                        </Box>
                        <input
                          type="number"
                          value={securityFormData.casualties.fatalities}
                          onChange={(e) =>
                            setSecurityFormData({
                              ...securityFormData,
                              casualties: {
                                ...securityFormData.casualties,
                                fatalities: parseInt(e.target.value, 10) || 0,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="0"
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Injuries
                        </Box>
                        <input
                          type="number"
                          value={securityFormData.casualties.injuries}
                          onChange={(e) =>
                            setSecurityFormData({
                              ...securityFormData,
                              casualties: {
                                ...securityFormData.casualties,
                                injuries: parseInt(e.target.value, 10) || 0,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="0"
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Missing
                        </Box>
                        <input
                          type="number"
                          value={securityFormData.casualties.missing}
                          onChange={(e) =>
                            setSecurityFormData({
                              ...securityFormData,
                              casualties: {
                                ...securityFormData.casualties,
                                missing: parseInt(e.target.value, 10) || 0,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="0"
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Response Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    🚨 RESPONSE & INVESTIGATION
                  </Box>
                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Response Team
                        </Box>
                        <input
                          type="text"
                          value={securityFormData.response_team}
                          onChange={(e) =>
                            setSecurityFormData({
                              ...securityFormData,
                              response_team: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., MTF Alpha-1, Security Team Bravo..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Investigation Lead
                        </Box>
                        <input
                          type="text"
                          value={securityFormData.investigation_lead}
                          onChange={(e) =>
                            setSecurityFormData({
                              ...securityFormData,
                              investigation_lead: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="Lead investigator name..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>

                  <Grid>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Response Time
                        </Box>
                        <input
                          type="text"
                          value={securityFormData.response_time}
                          onChange={(e) =>
                            setSecurityFormData({
                              ...securityFormData,
                              response_time: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 5 minutes, 30 seconds..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Containment Time
                        </Box>
                        <input
                          type="text"
                          value={securityFormData.containment_time}
                          onChange={(e) =>
                            setSecurityFormData({
                              ...securityFormData,
                              containment_time: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 15 minutes, 2 hours..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Investigation Status
                        </Box>
                        <select
                          value={securityFormData.investigation_status}
                          onChange={(e) =>
                            setSecurityFormData({
                              ...securityFormData,
                              investigation_status: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="pending">⏳ Pending</option>
                          <option value="ongoing">🔄 Ongoing</option>
                          <option value="completed">✅ Completed</option>
                          <option value="suspended">⏸️ Suspended</option>
                          <option value="closed">🔒 Closed</option>
                        </select>
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Action Buttons */}
                <Box
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    marginTop: '20px',
                    borderTop: '2px solid rgba(255,255,255,0.2)',
                    paddingTop: '20px',
                  }}
                >
                  <Box style={{ fontSize: '14px', opacity: '0.7' }}>
                    * Required fields must be completed
                  </Box>
                  <Box style={{ display: 'flex', gap: '15px' }}>
                    <EnhancedButton
                      onClick={() => setSecurityModalOpen(false)}
                      color="default"
                      tooltip="Cancel and close form"
                    >
                      ✕ Cancel
                    </EnhancedButton>
                    <EnhancedButton
                      color="good"
                      onClick={() => {
                        // Validate required fields
                        if (
                          !securityFormData.incident_id ||
                          !securityFormData.incident_type ||
                          !securityFormData.severity ||
                          !securityFormData.location ||
                          !securityFormData.date_time ||
                          !securityFormData.description
                        ) {
                          addNotification(
                            'Validation Error',
                            'Please complete all required fields',
                            'error',
                          );
                          return;
                        }

                        // Submit to backend
                        act('security_add_incident', {
                          incident_data: securityFormData,
                        });

                        // Show success notification
                        addNotification(
                          'Success',
                          'Security incident reported successfully',
                          'success',
                        );

                        // Reset form and close modal
                        setSecurityFormData({
                          incident_id: '',
                          incident_type: 'breach',
                          severity: 'low',
                          location: '',
                          date_time: '',
                          description: '',
                          involved_personnel: [],
                          involved_scps: [],
                          casualties: {
                            fatalities: 0,
                            injuries: 0,
                            missing: 0,
                          },
                          containment_status: 'contained',
                          threat_level: 'green',
                          response_team: '',
                          response_time: '',
                          containment_time: '',
                          investigation_status: 'pending',
                          investigation_lead: '',
                          evidence_collected: [],
                          witnesses: [],
                          security_breaches: [],
                          system_failures: [],
                          human_errors: [],
                          external_threats: [],
                          internal_threats: [],
                          anomalous_events: [],
                          containment_failures: [],
                          security_failures: [],
                          procedural_violations: [],
                          equipment_failures: [],
                          communication_failures: [],
                          coordination_failures: [],
                          response_delays: [],
                          investigation_findings: '',
                          corrective_actions: [],
                          preventive_measures: [],
                          security_upgrades: [],
                          personnel_training: [],
                          protocol_revisions: [],
                          equipment_upgrades: [],
                          system_upgrades: [],
                          facility_upgrades: [],
                          containment_upgrades: [],
                          monitoring_upgrades: [],
                          response_upgrades: [],
                          investigation_upgrades: [],
                          security_audit: false,
                          security_review: false,
                          security_assessment: false,
                          security_evaluation: false,
                          security_inspection: false,
                          security_testing: false,
                          security_monitoring: false,
                          security_tracking: false,
                          security_reporting: false,
                          security_documentation: false,
                          security_analysis: false,
                          security_planning: false,
                          security_coordination: false,
                          security_communication: false,
                          security_training: false,
                          security_awareness: false,
                          security_preparedness: false,
                          security_response: false,
                          security_recovery: false,
                          security_lessons: false,
                          security_improvements: false,
                          security_enhancements: false,
                          security_optimization: false,
                          security_modernization: false,
                          security_innovation: false,
                          security_development: false,
                          security_research: false,
                          security_testing_protocols: false,
                          security_monitoring_protocols: false,
                          security_response_protocols: false,
                          security_investigation_protocols: false,
                          security_documentation_protocols: false,
                          security_analysis_protocols: false,
                          security_planning_protocols: false,
                          security_coordination_protocols: false,
                          security_communication_protocols: false,
                          security_training_protocols: false,
                          security_awareness_protocols: false,
                          security_preparedness_protocols: false,
                          security_recovery_protocols: false,
                          security_lessons_protocols: false,
                          security_improvements_protocols: false,
                          security_enhancements_protocols: false,
                          security_optimization_protocols: false,
                          security_modernization_protocols: false,
                          security_innovation_protocols: false,
                          security_development_protocols: false,
                          security_research_protocols: false,
                        });
                        setSecurityModalOpen(false);
                      }}
                      tooltip="Report security incident"
                    >
                      🚨 Report Incident
                    </EnhancedButton>
                  </Box>
                </Box>
              </Box>
            </Box>
          </Box>
        )}

        {/* Personnel Modal - Global Access */}
        {personnelModalOpen && (
          <Box
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              background: 'rgba(0,0,0,0.85)',
              zIndex: 1000,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              backdropFilter: 'blur(5px)',
            }}
            onClick={() => setPersonnelModalOpen(false)}
          >
            <Box
              style={{
                background:
                  'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)',
                border: '2px solid rgba(255,255,255,0.3)',
                borderRadius: '15px',
                padding: '30px',
                width: '90vw',
                maxWidth: '1200px',
                maxHeight: '90vh',
                overflow: 'auto',
                position: 'relative',
                boxShadow: '0 20px 40px rgba(0,0,0,0.5)',
              }}
              onClick={(e) => e.stopPropagation()}
            >
              {/* Modal Header */}
              <Box
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  marginBottom: '25px',
                  borderBottom: '2px solid rgba(255,255,255,0.2)',
                  paddingBottom: '15px',
                }}
              >
                <Box
                  style={{
                    fontSize: '28px',
                    fontWeight: 'bold',
                    color: '#66ffff',
                  }}
                >
                  👤 NEW EMPLOYEE REGISTRATION
                </Box>
                <Box
                  style={{
                    cursor: 'pointer',
                    fontSize: '24px',
                    opacity: 0.7,
                    transition: 'opacity 0.2s ease',
                    padding: '5px',
                    borderRadius: '5px',
                  }}
                  onClick={() => setPersonnelModalOpen(false)}
                  onMouseEnter={(e) => (e.target.style.opacity = '1')}
                  onMouseLeave={(e) => (e.target.style.opacity = '0.7')}
                >
                  ✕
                </Box>
              </Box>

              {/* Form Content */}
              <Box
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '25px',
                }}
              >
                {/* Employee Information Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    👤 EMPLOYEE INFORMATION
                  </Box>
                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Employee ID *
                        </Box>
                        <input
                          type="text"
                          value={personnelFormData.employee_id}
                          onChange={(e) =>
                            setPersonnelFormData({
                              ...personnelFormData,
                              employee_id: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., EMP-2024-001, PERS-001..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Full Name *
                        </Box>
                        <input
                          type="text"
                          value={personnelFormData.name}
                          onChange={(e) =>
                            setPersonnelFormData({
                              ...personnelFormData,
                              name: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="Full name..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>

                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Position *
                        </Box>
                        <input
                          type="text"
                          value={personnelFormData.position}
                          onChange={(e) =>
                            setPersonnelFormData({
                              ...personnelFormData,
                              position: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., Security Officer, Researcher, Administrator..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Department *
                        </Box>
                        <input
                          type="text"
                          value={personnelFormData.department}
                          onChange={(e) =>
                            setPersonnelFormData({
                              ...personnelFormData,
                              department: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., Security, Research, Medical, Administration..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Security Clearance Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    🔐 SECURITY CLEARANCE
                  </Box>
                  <Grid>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Security Clearance *
                        </Box>
                        <select
                          value={personnelFormData.security_clearance}
                          onChange={(e) =>
                            setPersonnelFormData({
                              ...personnelFormData,
                              security_clearance: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="level_1">🔓 Level 1 - Basic</option>
                          <option value="level_2">
                            🔒 Level 2 - Restricted
                          </option>
                          <option value="level_3">
                            🔐 Level 3 - Confidential
                          </option>
                          <option value="level_4">🔐 Level 4 - Secret</option>
                          <option value="level_5">
                            🔐 Level 5 - Top Secret
                          </option>
                        </select>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Access Level
                        </Box>
                        <select
                          value={personnelFormData.access_level}
                          onChange={(e) =>
                            setPersonnelFormData({
                              ...personnelFormData,
                              access_level: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="basic">🔓 Basic</option>
                          <option value="standard">🔒 Standard</option>
                          <option value="elevated">🔐 Elevated</option>
                          <option value="administrative">
                            ⚡ Administrative
                          </option>
                          <option value="executive">👑 Executive</option>
                        </select>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Hire Date
                        </Box>
                        <input
                          type="text"
                          value={personnelFormData.hire_date}
                          onChange={(e) =>
                            setPersonnelFormData({
                              ...personnelFormData,
                              hire_date: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 2024-01-15..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Contact Information Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    📞 CONTACT INFORMATION
                  </Box>
                  <Grid>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Phone Number
                        </Box>
                        <input
                          type="text"
                          value={personnelFormData.contact_info.phone}
                          onChange={(e) =>
                            setPersonnelFormData({
                              ...personnelFormData,
                              contact_info: {
                                ...personnelFormData.contact_info,
                                phone: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="Phone number..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Email Address
                        </Box>
                        <input
                          type="email"
                          value={personnelFormData.contact_info.email}
                          onChange={(e) =>
                            setPersonnelFormData({
                              ...personnelFormData,
                              contact_info: {
                                ...personnelFormData.contact_info,
                                email: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="Email address..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Emergency Contact
                        </Box>
                        <input
                          type="text"
                          value={
                            personnelFormData.contact_info.emergency_contact
                          }
                          onChange={(e) =>
                            setPersonnelFormData({
                              ...personnelFormData,
                              contact_info: {
                                ...personnelFormData.contact_info,
                                emergency_contact: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="Emergency contact..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Action Buttons */}
                <Box
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    marginTop: '20px',
                    borderTop: '2px solid rgba(255,255,255,0.2)',
                    paddingTop: '20px',
                  }}
                >
                  <Box style={{ fontSize: '14px', opacity: '0.7' }}>
                    * Required fields must be completed
                  </Box>
                  <Box style={{ display: 'flex', gap: '15px' }}>
                    <EnhancedButton
                      onClick={() => setPersonnelModalOpen(false)}
                      color="default"
                      tooltip="Cancel and close form"
                    >
                      ✕ Cancel
                    </EnhancedButton>
                    <EnhancedButton
                      color="good"
                      onClick={() => {
                        // Validate required fields
                        if (
                          !personnelFormData.employee_id ||
                          !personnelFormData.name ||
                          !personnelFormData.position ||
                          !personnelFormData.department ||
                          !personnelFormData.security_clearance
                        ) {
                          addNotification(
                            'Validation Error',
                            'Please complete all required fields',
                            'error',
                          );
                          return;
                        }

                        // Submit to backend
                        act('personnel_add_record', {
                          employee_data: personnelFormData,
                        });

                        // Show success notification
                        addNotification(
                          'Success',
                          'Employee registered successfully',
                          'success',
                        );

                        // Reset form and close modal
                        setPersonnelFormData({
                          employee_id: '',
                          name: '',
                          position: '',
                          department: '',
                          security_clearance: 'level_1',
                          access_level: 'basic',
                          hire_date: '',
                          supervisor: '',
                          contact_info: {
                            phone: '',
                            email: '',
                            emergency_contact: '',
                          },
                          qualifications: [],
                          certifications: [],
                          training_completed: [],
                          performance_rating: 'satisfactory',
                          status: 'active',
                          location: '',
                          schedule: '',
                          salary: '',
                          benefits: [],
                          medical_clearance: false,
                          psychological_clearance: false,
                          background_check: false,
                          drug_test: false,
                          polygraph_test: false,
                          security_interview: false,
                          clearance_review_date: '',
                          next_review_date: '',
                          incident_history: [],
                          commendations: [],
                          disciplinary_actions: [],
                          assignments: [],
                          projects: [],
                          skills: [],
                          languages: [],
                          equipment_authorized: [],
                          facility_access: [],
                          system_access: [],
                          clearance_level: 'level_1',
                          clearance_type: 'standard',
                          clearance_status: 'active',
                          clearance_expiry: '',
                          clearance_renewal: '',
                          clearance_conditions: [],
                          clearance_restrictions: [],
                          clearance_notes: '',
                          security_briefing: false,
                          security_training: false,
                          security_awareness: false,
                          security_compliance: false,
                          security_audit: false,
                          security_review: false,
                          security_assessment: false,
                          security_evaluation: false,
                          security_inspection: false,
                          security_testing: false,
                          security_monitoring: false,
                          security_tracking: false,
                          security_reporting: false,
                          security_documentation: false,
                          security_analysis: false,
                          security_planning: false,
                          security_coordination: false,
                          security_communication: false,
                          security_training_completed: false,
                          security_awareness_completed: false,
                          security_preparedness: false,
                          security_response: false,
                          security_recovery: false,
                          security_lessons: false,
                          security_improvements: false,
                          security_enhancements: false,
                          security_optimization: false,
                          security_modernization: false,
                          security_innovation: false,
                          security_development: false,
                          security_research: false,
                        });
                        setPersonnelModalOpen(false);
                      }}
                      tooltip="Register employee"
                    >
                      👤 Register Employee
                    </EnhancedButton>
                  </Box>
                </Box>
              </Box>
            </Box>
          </Box>
        )}

        {/* Technology Modal - Global Access */}
        {technologyModalOpen && (
          <Box
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              background: 'rgba(0,0,0,0.85)',
              zIndex: 1000,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              backdropFilter: 'blur(5px)',
            }}
            onClick={() => setTechnologyModalOpen(false)}
          >
            <Box
              style={{
                background:
                  'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)',
                border: '2px solid rgba(255,255,255,0.3)',
                borderRadius: '15px',
                padding: '30px',
                width: '90vw',
                maxWidth: '1200px',
                maxHeight: '90vh',
                overflow: 'auto',
                position: 'relative',
                boxShadow: '0 20px 40px rgba(0,0,0,0.5)',
              }}
              onClick={(e) => e.stopPropagation()}
            >
              {/* Modal Header */}
              <Box
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  marginBottom: '25px',
                  borderBottom: '2px solid rgba(255,255,255,0.2)',
                  paddingBottom: '15px',
                }}
              >
                <Box
                  style={{
                    fontSize: '28px',
                    fontWeight: 'bold',
                    color: '#66ffff',
                  }}
                >
                  ⚡ NEW TECHNOLOGY REGISTRATION
                </Box>
                <Box
                  style={{
                    cursor: 'pointer',
                    fontSize: '24px',
                    opacity: 0.7,
                    transition: 'opacity 0.2s ease',
                    padding: '5px',
                    borderRadius: '5px',
                  }}
                  onClick={() => setTechnologyModalOpen(false)}
                  onMouseEnter={(e) => (e.target.style.opacity = '1')}
                  onMouseLeave={(e) => (e.target.style.opacity = '0.7')}
                >
                  ✕
                </Box>
              </Box>

              {/* Form Content */}
              <Box
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '25px',
                }}
              >
                {/* Device Information Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    ⚡ DEVICE INFORMATION
                  </Box>
                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Device ID *
                        </Box>
                        <input
                          type="text"
                          value={technologyFormData.device_id}
                          onChange={(e) =>
                            setTechnologyFormData({
                              ...technologyFormData,
                              device_id: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., TECH-2024-001, DEV-001..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Device Name *
                        </Box>
                        <input
                          type="text"
                          value={technologyFormData.device_name}
                          onChange={(e) =>
                            setTechnologyFormData({
                              ...technologyFormData,
                              device_name: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., Mainframe Alpha, Security Terminal..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>

                  <Grid>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Device Type *
                        </Box>
                        <select
                          value={technologyFormData.device_type}
                          onChange={(e) =>
                            setTechnologyFormData({
                              ...technologyFormData,
                              device_type: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="computer">💻 Computer</option>
                          <option value="server">🖥️ Server</option>
                          <option value="terminal">🖱️ Terminal</option>
                          <option value="network">🌐 Network Device</option>
                          <option value="security">🔒 Security Device</option>
                          <option value="monitoring">
                            📊 Monitoring Device
                          </option>
                          <option value="communication">
                            📡 Communication Device
                          </option>
                          <option value="research">
                            🔬 Research Equipment
                          </option>
                          <option value="medical">🏥 Medical Device</option>
                          <option value="containment">
                            🛡️ Containment Device
                          </option>
                          <option value="other">⚙️ Other</option>
                        </select>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Manufacturer
                        </Box>
                        <input
                          type="text"
                          value={technologyFormData.manufacturer}
                          onChange={(e) =>
                            setTechnologyFormData({
                              ...technologyFormData,
                              manufacturer: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., Foundation Tech, SecureCorp..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Model
                        </Box>
                        <input
                          type="text"
                          value={technologyFormData.model}
                          onChange={(e) =>
                            setTechnologyFormData({
                              ...technologyFormData,
                              model: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., XT-5000, SecureTerm-2024..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>

                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Serial Number
                        </Box>
                        <input
                          type="text"
                          value={technologyFormData.serial_number}
                          onChange={(e) =>
                            setTechnologyFormData({
                              ...technologyFormData,
                              serial_number: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="Device serial number..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Location
                        </Box>
                        <input
                          type="text"
                          value={technologyFormData.location}
                          onChange={(e) =>
                            setTechnologyFormData({
                              ...technologyFormData,
                              location: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., Server Room A, Security Office..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Specifications Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    🔧 TECHNICAL SPECIFICATIONS
                  </Box>
                  <Grid>
                    <Grid.Column size={2}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Processor
                        </Box>
                        <input
                          type="text"
                          value={technologyFormData.specifications.processor}
                          onChange={(e) =>
                            setTechnologyFormData({
                              ...technologyFormData,
                              specifications: {
                                ...technologyFormData.specifications,
                                processor: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., Intel i7, AMD Ryzen..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={2}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Memory
                        </Box>
                        <input
                          type="text"
                          value={technologyFormData.specifications.memory}
                          onChange={(e) =>
                            setTechnologyFormData({
                              ...technologyFormData,
                              specifications: {
                                ...technologyFormData.specifications,
                                memory: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 16GB RAM..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={2}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Storage
                        </Box>
                        <input
                          type="text"
                          value={technologyFormData.specifications.storage}
                          onChange={(e) =>
                            setTechnologyFormData({
                              ...technologyFormData,
                              specifications: {
                                ...technologyFormData.specifications,
                                storage: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 1TB SSD..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={2}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Network
                        </Box>
                        <input
                          type="text"
                          value={technologyFormData.specifications.network}
                          onChange={(e) =>
                            setTechnologyFormData({
                              ...technologyFormData,
                              specifications: {
                                ...technologyFormData.specifications,
                                network: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 1Gbps Ethernet..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={2}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Operating System
                        </Box>
                        <input
                          type="text"
                          value={technologyFormData.specifications.os}
                          onChange={(e) =>
                            setTechnologyFormData({
                              ...technologyFormData,
                              specifications: {
                                ...technologyFormData.specifications,
                                os: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., Windows 11, Linux..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Status & Maintenance Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    📊 STATUS & MAINTENANCE
                  </Box>
                  <Grid>
                    <Grid.Column size={3}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Status *
                        </Box>
                        <select
                          value={technologyFormData.status}
                          onChange={(e) =>
                            setTechnologyFormData({
                              ...technologyFormData,
                              status: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="operational">🟢 Operational</option>
                          <option value="maintenance">🟡 Maintenance</option>
                          <option value="offline">🔴 Offline</option>
                          <option value="testing">🟠 Testing</option>
                          <option value="decommissioned">
                            ⚫ Decommissioned
                          </option>
                        </select>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Purchase Date
                        </Box>
                        <input
                          type="text"
                          value={technologyFormData.purchase_date}
                          onChange={(e) =>
                            setTechnologyFormData({
                              ...technologyFormData,
                              purchase_date: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 2024-01-15..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Last Maintenance
                        </Box>
                        <input
                          type="text"
                          value={technologyFormData.last_maintenance}
                          onChange={(e) =>
                            setTechnologyFormData({
                              ...technologyFormData,
                              last_maintenance: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 2024-01-15..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Next Maintenance
                        </Box>
                        <input
                          type="text"
                          value={technologyFormData.next_maintenance}
                          onChange={(e) =>
                            setTechnologyFormData({
                              ...technologyFormData,
                              next_maintenance: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 2024-07-15..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Action Buttons */}
                <Box
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    marginTop: '20px',
                    borderTop: '2px solid rgba(255,255,255,0.2)',
                    paddingTop: '20px',
                  }}
                >
                  <Box style={{ fontSize: '14px', opacity: '0.7' }}>
                    * Required fields must be completed
                  </Box>
                  <Box style={{ display: 'flex', gap: '15px' }}>
                    <EnhancedButton
                      onClick={() => setTechnologyModalOpen(false)}
                      color="default"
                      tooltip="Cancel and close form"
                    >
                      ✕ Cancel
                    </EnhancedButton>
                    <EnhancedButton
                      color="good"
                      onClick={() => {
                        // Validate required fields
                        if (
                          !technologyFormData.device_id ||
                          !technologyFormData.device_name ||
                          !technologyFormData.device_type ||
                          !technologyFormData.status
                        ) {
                          addNotification(
                            'Validation Error',
                            'Please complete all required fields',
                            'error',
                          );
                          return;
                        }

                        // Submit to backend
                        act('technology_add_tech', {
                          technology_data: technologyFormData,
                        });

                        // Show success notification
                        addNotification(
                          'Success',
                          'Technology device registered successfully',
                          'success',
                        );

                        // Reset form and close modal
                        setTechnologyFormData({
                          device_id: '',
                          device_name: '',
                          device_type: 'computer',
                          manufacturer: '',
                          model: '',
                          serial_number: '',
                          location: '',
                          assigned_to: '',
                          department: '',
                          status: 'operational',
                          purchase_date: '',
                          warranty_expiry: '',
                          last_maintenance: '',
                          next_maintenance: '',
                          specifications: {
                            processor: '',
                            memory: '',
                            storage: '',
                            network: '',
                            os: '',
                          },
                          software_installed: [],
                          security_software: [],
                          access_controls: [],
                          monitoring_systems: [],
                          backup_systems: [],
                          redundancy_systems: [],
                          failover_systems: [],
                          disaster_recovery: [],
                          maintenance_schedule: '',
                          maintenance_history: [],
                          repair_history: [],
                          upgrade_history: [],
                          replacement_history: [],
                          cost_information: {
                            purchase_cost: '',
                            maintenance_cost: '',
                            operational_cost: '',
                            replacement_cost: '',
                          },
                          performance_metrics: {
                            uptime: '',
                            response_time: '',
                            throughput: '',
                            efficiency: '',
                          },
                          security_features: [],
                          vulnerabilities: [],
                          patches_installed: [],
                          updates_pending: [],
                          compliance_status: 'compliant',
                          audit_status: 'passed',
                          certification_status: 'certified',
                          testing_status: 'passed',
                          monitoring_status: 'active',
                          tracking_status: 'active',
                          reporting_status: 'active',
                          documentation_status: 'complete',
                          analysis_status: 'complete',
                          planning_status: 'complete',
                          coordination_status: 'complete',
                          communication_status: 'active',
                          training_status: 'complete',
                          awareness_status: 'complete',
                          preparedness_status: 'complete',
                          response_status: 'ready',
                          recovery_status: 'ready',
                          lessons_status: 'complete',
                          improvements_status: 'complete',
                          enhancements_status: 'complete',
                          optimization_status: 'complete',
                          modernization_status: 'complete',
                          innovation_status: 'complete',
                          development_status: 'complete',
                          research_status: 'complete',
                        });
                        setTechnologyModalOpen(false);
                      }}
                      tooltip="Register technology device"
                    >
                      ⚡ Register Technology
                    </EnhancedButton>
                  </Box>
                </Box>
              </Box>
            </Box>
          </Box>
        )}

        {/* Facility Modal - Global Access */}
        {facilityModalOpen && (
          <Box
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              background: 'rgba(0,0,0,0.85)',
              zIndex: 1000,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              backdropFilter: 'blur(5px)',
            }}
            onClick={() => setFacilityModalOpen(false)}
          >
            <Box
              style={{
                background:
                  'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)',
                border: '2px solid rgba(255,255,255,0.3)',
                borderRadius: '15px',
                padding: '30px',
                width: '90vw',
                maxWidth: '1200px',
                maxHeight: '90vh',
                overflow: 'auto',
                position: 'relative',
                boxShadow: '0 20px 40px rgba(0,0,0,0.5)',
              }}
              onClick={(e) => e.stopPropagation()}
            >
              {/* Modal Header */}
              <Box
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  marginBottom: '25px',
                  borderBottom: '2px solid rgba(255,255,255,0.2)',
                  paddingBottom: '15px',
                }}
              >
                <Box
                  style={{
                    fontSize: '28px',
                    fontWeight: 'bold',
                    color: '#66ffff',
                  }}
                >
                  🏢 NEW FACILITY REGISTRATION
                </Box>
                <Box
                  style={{
                    cursor: 'pointer',
                    fontSize: '24px',
                    opacity: 0.7,
                    transition: 'opacity 0.2s ease',
                    padding: '5px',
                    borderRadius: '5px',
                  }}
                  onClick={() => setFacilityModalOpen(false)}
                  onMouseEnter={(e) => (e.target.style.opacity = '1')}
                  onMouseLeave={(e) => (e.target.style.opacity = '0.7')}
                >
                  ✕
                </Box>
              </Box>

              {/* Form Content */}
              <Box
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '25px',
                }}
              >
                {/* Facility Information Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    🏢 FACILITY INFORMATION
                  </Box>
                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Facility ID *
                        </Box>
                        <input
                          type="text"
                          value={facilityFormData.facility_id}
                          onChange={(e) =>
                            setFacilityFormData({
                              ...facilityFormData,
                              facility_id: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., SITE-19, FAC-001, COMPLEX-A..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Facility Name *
                        </Box>
                        <input
                          type="text"
                          value={facilityFormData.facility_name}
                          onChange={(e) =>
                            setFacilityFormData({
                              ...facilityFormData,
                              facility_name: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., Site-19, Research Complex Alpha..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>

                  <Grid>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Facility Type *
                        </Box>
                        <select
                          value={facilityFormData.facility_type}
                          onChange={(e) =>
                            setFacilityFormData({
                              ...facilityFormData,
                              facility_type: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="site">🏢 Site</option>
                          <option value="complex">🏗️ Complex</option>
                          <option value="facility">🏭 Facility</option>
                          <option value="base">🏛️ Base</option>
                          <option value="station">🚉 Station</option>
                          <option value="outpost">🏕️ Outpost</option>
                          <option value="laboratory">🧪 Laboratory</option>
                          <option value="containment">🛡️ Containment</option>
                          <option value="research">🔬 Research</option>
                          <option value="medical">🏥 Medical</option>
                          <option value="administrative">
                            📋 Administrative
                          </option>
                          <option value="storage">📦 Storage</option>
                          <option value="transportation">
                            🚚 Transportation
                          </option>
                          <option value="other">⚙️ Other</option>
                        </select>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Status
                        </Box>
                        <select
                          value={facilityFormData.status}
                          onChange={(e) =>
                            setFacilityFormData({
                              ...facilityFormData,
                              status: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="operational">🟢 Operational</option>
                          <option value="construction">
                            🟡 Under Construction
                          </option>
                          <option value="maintenance">🟠 Maintenance</option>
                          <option value="decommissioned">
                            🔴 Decommissioned
                          </option>
                          <option value="quarantine">🚨 Quarantine</option>
                          <option value="standby">⚪ Standby</option>
                        </select>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Security Level
                        </Box>
                        <select
                          value={facilityFormData.security_level}
                          onChange={(e) =>
                            setFacilityFormData({
                              ...facilityFormData,
                              security_level: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="level_1">🔓 Level 1 - Basic</option>
                          <option value="level_2">
                            🔒 Level 2 - Restricted
                          </option>
                          <option value="level_3">
                            🔐 Level 3 - Confidential
                          </option>
                          <option value="level_4">🔐 Level 4 - Secret</option>
                          <option value="level_5">
                            🔐 Level 5 - Top Secret
                          </option>
                        </select>
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Location Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    📍 LOCATION INFORMATION
                  </Box>
                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Address
                        </Box>
                        <input
                          type="text"
                          value={facilityFormData.location.address}
                          onChange={(e) =>
                            setFacilityFormData({
                              ...facilityFormData,
                              location: {
                                ...facilityFormData.location,
                                address: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="Street address..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          City
                        </Box>
                        <input
                          type="text"
                          value={facilityFormData.location.city}
                          onChange={(e) =>
                            setFacilityFormData({
                              ...facilityFormData,
                              location: {
                                ...facilityFormData.location,
                                city: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="City..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>

                  <Grid>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          State/Province
                        </Box>
                        <input
                          type="text"
                          value={facilityFormData.location.state}
                          onChange={(e) =>
                            setFacilityFormData({
                              ...facilityFormData,
                              location: {
                                ...facilityFormData.location,
                                state: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="State/Province..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Country
                        </Box>
                        <input
                          type="text"
                          value={facilityFormData.location.country}
                          onChange={(e) =>
                            setFacilityFormData({
                              ...facilityFormData,
                              location: {
                                ...facilityFormData.location,
                                country: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="Country..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Coordinates
                        </Box>
                        <input
                          type="text"
                          value={facilityFormData.location.coordinates}
                          onChange={(e) =>
                            setFacilityFormData({
                              ...facilityFormData,
                              location: {
                                ...facilityFormData.location,
                                coordinates: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 40.7128° N, 74.0060° W..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Capacity Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    📊 CAPACITY & CAPABILITIES
                  </Box>
                  <Grid>
                    <Grid.Column size={3}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Personnel Capacity
                        </Box>
                        <input
                          type="text"
                          value={facilityFormData.capacity.personnel}
                          onChange={(e) =>
                            setFacilityFormData({
                              ...facilityFormData,
                              capacity: {
                                ...facilityFormData.capacity,
                                personnel: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 500, 1000+..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Equipment Capacity
                        </Box>
                        <input
                          type="text"
                          value={facilityFormData.capacity.equipment}
                          onChange={(e) =>
                            setFacilityFormData({
                              ...facilityFormData,
                              capacity: {
                                ...facilityFormData.capacity,
                                equipment: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 200 units, unlimited..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Storage Capacity
                        </Box>
                        <input
                          type="text"
                          value={facilityFormData.capacity.storage}
                          onChange={(e) =>
                            setFacilityFormData({
                              ...facilityFormData,
                              capacity: {
                                ...facilityFormData.capacity,
                                storage: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 10,000 sq ft, 50,000 cubic meters..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Containment Capacity
                        </Box>
                        <input
                          type="text"
                          value={facilityFormData.capacity.containment}
                          onChange={(e) =>
                            setFacilityFormData({
                              ...facilityFormData,
                              capacity: {
                                ...facilityFormData.capacity,
                                containment: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 50 cells, 100 chambers..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Action Buttons */}
                <Box
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    marginTop: '20px',
                    borderTop: '2px solid rgba(255,255,255,0.2)',
                    paddingTop: '20px',
                  }}
                >
                  <Box style={{ fontSize: '14px', opacity: '0.7' }}>
                    * Required fields must be completed
                  </Box>
                  <Box style={{ display: 'flex', gap: '15px' }}>
                    <EnhancedButton
                      onClick={() => setFacilityModalOpen(false)}
                      color="default"
                      tooltip="Cancel and close form"
                    >
                      ✕ Cancel
                    </EnhancedButton>
                    <EnhancedButton
                      color="good"
                      onClick={() => {
                        // Validate required fields
                        if (
                          !facilityFormData.facility_id ||
                          !facilityFormData.facility_name ||
                          !facilityFormData.facility_type
                        ) {
                          addNotification(
                            'Validation Error',
                            'Please complete all required fields',
                            'error',
                          );
                          return;
                        }

                        // Submit to backend
                        act('facility_add_facility', {
                          facility_data: facilityFormData,
                        });

                        // Show success notification
                        addNotification(
                          'Success',
                          'Facility registered successfully',
                          'success',
                        );

                        // Reset form and close modal
                        setFacilityFormData({
                          facility_id: '',
                          facility_name: '',
                          facility_type: 'site',
                          location: {
                            address: '',
                            city: '',
                            state: '',
                            country: '',
                            coordinates: '',
                          },
                          capacity: {
                            personnel: '',
                            equipment: '',
                            storage: '',
                            containment: '',
                          },
                          status: 'operational',
                          security_level: 'level_1',
                          containment_level: 'level_1',
                          construction_date: '',
                          last_renovation: '',
                          next_renovation: '',
                          departments: [],
                          personnel_assigned: [],
                          equipment_installed: [],
                          systems_installed: [],
                          security_systems: [],
                          containment_systems: [],
                          monitoring_systems: [],
                          communication_systems: [],
                          power_systems: [],
                          environmental_systems: [],
                          maintenance_systems: [],
                          backup_systems: [],
                          emergency_systems: [],
                          safety_systems: [],
                          fire_suppression: [],
                          ventilation_systems: [],
                          water_systems: [],
                          waste_systems: [],
                          telecommunications: [],
                          data_systems: [],
                          laboratory_systems: [],
                          medical_systems: [],
                          research_systems: [],
                          administrative_systems: [],
                          operational_systems: [],
                          logistical_systems: [],
                          transportation_systems: [],
                          storage_systems: [],
                          archival_systems: [],
                          security_clearance: 'level_1',
                          access_controls: [],
                          monitoring_equipment: [],
                          surveillance_systems: [],
                          alarm_systems: [],
                          response_systems: [],
                          emergency_protocols: [],
                          evacuation_procedures: [],
                          lockdown_procedures: [],
                          containment_procedures: [],
                          security_procedures: [],
                          safety_procedures: [],
                          maintenance_procedures: [],
                          operational_procedures: [],
                          administrative_procedures: [],
                          logistical_procedures: [],
                          transportation_procedures: [],
                          storage_procedures: [],
                          archival_procedures: [],
                          compliance_status: 'compliant',
                          audit_status: 'passed',
                          certification_status: 'certified',
                          testing_status: 'passed',
                          monitoring_status: 'active',
                          tracking_status: 'active',
                          reporting_status: 'active',
                          documentation_status: 'complete',
                          analysis_status: 'complete',
                          planning_status: 'complete',
                          coordination_status: 'complete',
                          communication_status: 'active',
                          training_status: 'complete',
                          awareness_status: 'complete',
                          preparedness_status: 'complete',
                          response_status: 'ready',
                          recovery_status: 'ready',
                          lessons_status: 'complete',
                          improvements_status: 'complete',
                          enhancements_status: 'complete',
                          optimization_status: 'complete',
                          modernization_status: 'complete',
                          innovation_status: 'complete',
                          development_status: 'complete',
                          research_status: 'complete',
                        });
                        setFacilityModalOpen(false);
                      }}
                      tooltip="Register facility"
                    >
                      🏢 Register Facility
                    </EnhancedButton>
                  </Box>
                </Box>
              </Box>
            </Box>
          </Box>
        )}

        {/* Analytics Report Modal - Global Access */}
        {analyticsReportModalOpen && (
          <Box
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              background: 'rgba(0,0,0,0.85)',
              zIndex: 1000,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              backdropFilter: 'blur(5px)',
            }}
            onClick={() => setAnalyticsReportModalOpen(false)}
          >
            <Box
              style={{
                background:
                  'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)',
                border: '2px solid rgba(255,255,255,0.3)',
                borderRadius: '15px',
                padding: '30px',
                width: '90vw',
                maxWidth: '1200px',
                maxHeight: '90vh',
                overflow: 'auto',
                position: 'relative',
                boxShadow: '0 20px 40px rgba(0,0,0,0.5)',
              }}
              onClick={(e) => e.stopPropagation()}
            >
              {/* Modal Header */}
              <Box
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  marginBottom: '25px',
                  borderBottom: '2px solid rgba(255,255,255,0.2)',
                  paddingBottom: '15px',
                }}
              >
                <Box
                  style={{
                    fontSize: '28px',
                    fontWeight: 'bold',
                    color: '#66ffff',
                  }}
                >
                  📄 ANALYTICS REPORT GENERATOR
                </Box>
                <Box
                  style={{
                    cursor: 'pointer',
                    fontSize: '24px',
                    opacity: 0.7,
                    transition: 'opacity 0.2s ease',
                    padding: '5px',
                    borderRadius: '5px',
                  }}
                  onClick={() => setAnalyticsReportModalOpen(false)}
                  onMouseEnter={(e) => (e.target.style.opacity = '1')}
                  onMouseLeave={(e) => (e.target.style.opacity = '0.7')}
                >
                  ✕
                </Box>
              </Box>

              {/* Form Content */}
              <Box
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '25px',
                }}
              >
                {/* Report Information Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    📄 REPORT INFORMATION
                  </Box>
                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Report ID *
                        </Box>
                        <input
                          type="text"
                          value={analyticsReportFormData.report_id}
                          onChange={(e) =>
                            setAnalyticsReportFormData({
                              ...analyticsReportFormData,
                              report_id: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., RPT-2024-001, ANALYTICS-001..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Report Title *
                        </Box>
                        <input
                          type="text"
                          value={analyticsReportFormData.report_title}
                          onChange={(e) =>
                            setAnalyticsReportFormData({
                              ...analyticsReportFormData,
                              report_title: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., Q4 Performance Analysis..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>

                  <Grid>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Report Type *
                        </Box>
                        <select
                          value={analyticsReportFormData.report_type}
                          onChange={(e) =>
                            setAnalyticsReportFormData({
                              ...analyticsReportFormData,
                              report_type: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="performance">📊 Performance</option>
                          <option value="efficiency">⚡ Efficiency</option>
                          <option value="trend">📈 Trend Analysis</option>
                          <option value="comparative">🔄 Comparative</option>
                          <option value="predictive">🔮 Predictive</option>
                          <option value="statistical">📋 Statistical</option>
                          <option value="executive">
                            👑 Executive Summary
                          </option>
                          <option value="operational">⚙️ Operational</option>
                          <option value="security">🔒 Security</option>
                          <option value="research">🔬 Research</option>
                          <option value="custom">🎨 Custom</option>
                        </select>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Format
                        </Box>
                        <select
                          value={analyticsReportFormData.format}
                          onChange={(e) =>
                            setAnalyticsReportFormData({
                              ...analyticsReportFormData,
                              format: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="pdf">📄 PDF</option>
                          <option value="excel">📊 Excel</option>
                          <option value="csv">📋 CSV</option>
                          <option value="json">🔧 JSON</option>
                          <option value="html">🌐 HTML</option>
                          <option value="powerpoint">📽️ PowerPoint</option>
                        </select>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Priority
                        </Box>
                        <select
                          value={analyticsReportFormData.priority}
                          onChange={(e) =>
                            setAnalyticsReportFormData({
                              ...analyticsReportFormData,
                              priority: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="low">🟢 Low</option>
                          <option value="normal">🟡 Normal</option>
                          <option value="high">🟠 High</option>
                          <option value="urgent">🔴 Urgent</option>
                        </select>
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Date Range Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    📅 DATE RANGE
                  </Box>
                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Start Date
                        </Box>
                        <input
                          type="text"
                          value={analyticsReportFormData.date_range.start_date}
                          onChange={(e) =>
                            setAnalyticsReportFormData({
                              ...analyticsReportFormData,
                              date_range: {
                                ...analyticsReportFormData.date_range,
                                start_date: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 2024-01-01..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          End Date
                        </Box>
                        <input
                          type="text"
                          value={analyticsReportFormData.date_range.end_date}
                          onChange={(e) =>
                            setAnalyticsReportFormData({
                              ...analyticsReportFormData,
                              date_range: {
                                ...analyticsReportFormData.date_range,
                                end_date: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 2024-12-31..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Metrics Selection Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    📊 METRICS TO INCLUDE
                  </Box>
                  <Grid>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              analyticsReportFormData.metrics_included
                                .performance_metrics
                            }
                            onChange={(e) =>
                              setAnalyticsReportFormData({
                                ...analyticsReportFormData,
                                metrics_included: {
                                  ...analyticsReportFormData.metrics_included,
                                  performance_metrics: e.target.checked,
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            📊 Performance Metrics
                          </span>
                        </label>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              analyticsReportFormData.metrics_included
                                .efficiency_data
                            }
                            onChange={(e) =>
                              setAnalyticsReportFormData({
                                ...analyticsReportFormData,
                                metrics_included: {
                                  ...analyticsReportFormData.metrics_included,
                                  efficiency_data: e.target.checked,
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            ⚡ Efficiency Data
                          </span>
                        </label>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              analyticsReportFormData.metrics_included
                                .trend_analysis
                            }
                            onChange={(e) =>
                              setAnalyticsReportFormData({
                                ...analyticsReportFormData,
                                metrics_included: {
                                  ...analyticsReportFormData.metrics_included,
                                  trend_analysis: e.target.checked,
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            📈 Trend Analysis
                          </span>
                        </label>
                      </Box>
                    </Grid.Column>
                  </Grid>
                  <Grid>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              analyticsReportFormData.metrics_included
                                .comparative_data
                            }
                            onChange={(e) =>
                              setAnalyticsReportFormData({
                                ...analyticsReportFormData,
                                metrics_included: {
                                  ...analyticsReportFormData.metrics_included,
                                  comparative_data: e.target.checked,
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            🔄 Comparative Data
                          </span>
                        </label>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              analyticsReportFormData.metrics_included
                                .predictive_analytics
                            }
                            onChange={(e) =>
                              setAnalyticsReportFormData({
                                ...analyticsReportFormData,
                                metrics_included: {
                                  ...analyticsReportFormData.metrics_included,
                                  predictive_analytics: e.target.checked,
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            🔮 Predictive Analytics
                          </span>
                        </label>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              analyticsReportFormData.metrics_included
                                .statistical_summary
                            }
                            onChange={(e) =>
                              setAnalyticsReportFormData({
                                ...analyticsReportFormData,
                                metrics_included: {
                                  ...analyticsReportFormData.metrics_included,
                                  statistical_summary: e.target.checked,
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            📋 Statistical Summary
                          </span>
                        </label>
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Action Buttons */}
                <Box
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    marginTop: '20px',
                    borderTop: '2px solid rgba(255,255,255,0.2)',
                    paddingTop: '20px',
                  }}
                >
                  <Box style={{ fontSize: '14px', opacity: '0.7' }}>
                    * Required fields must be completed
                  </Box>
                  <Box style={{ display: 'flex', gap: '15px' }}>
                    <EnhancedButton
                      onClick={() => setAnalyticsReportModalOpen(false)}
                      color="default"
                      tooltip="Cancel and close form"
                    >
                      ✕ Cancel
                    </EnhancedButton>
                    <EnhancedButton
                      color="good"
                      onClick={() => {
                        // Validate required fields
                        if (
                          !analyticsReportFormData.report_id ||
                          !analyticsReportFormData.report_title ||
                          !analyticsReportFormData.report_type
                        ) {
                          addNotification(
                            'Validation Error',
                            'Please complete all required fields',
                            'error',
                          );
                          return;
                        }

                        // Submit to backend
                        act('analytics_generate_report', {
                          report_data: analyticsReportFormData,
                        });

                        // Show success notification
                        addNotification(
                          'Success',
                          'Analytics report generation initiated',
                          'success',
                        );

                        // Reset form and close modal
                        setAnalyticsReportFormData({
                          report_id: '',
                          report_title: '',
                          report_type: 'performance',
                          date_range: {
                            start_date: '',
                            end_date: '',
                          },
                          metrics_included: {
                            performance_metrics: true,
                            efficiency_data: true,
                            trend_analysis: true,
                            comparative_data: true,
                            predictive_analytics: true,
                            statistical_summary: true,
                          },
                          data_sources: [],
                          filters: {
                            department: 'all',
                            facility: 'all',
                            time_period: 'monthly',
                            data_quality: 'all',
                          },
                          format: 'pdf',
                          delivery_method: 'download',
                          recipients: [],
                          custom_parameters: {
                            confidence_level: '95',
                            significance_level: '0.05',
                            sample_size: 'auto',
                            outlier_detection: true,
                            trend_forecasting: true,
                          },
                          visualization_options: {
                            charts: true,
                            graphs: true,
                            tables: true,
                            heatmaps: true,
                            dashboards: true,
                          },
                          analysis_depth: 'comprehensive',
                          priority: 'normal',
                          notes: '',
                        });
                        setAnalyticsReportModalOpen(false);
                      }}
                      tooltip="Generate analytics report"
                    >
                      📄 Generate Report
                    </EnhancedButton>
                  </Box>
                </Box>
              </Box>
            </Box>
          </Box>
        )}

        {/* Analytics KPI Dashboard Modal - Global Access */}
        {analyticsKpiModalOpen && (
          <Box
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              background: 'rgba(0,0,0,0.85)',
              zIndex: 1000,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              backdropFilter: 'blur(5px)',
            }}
            onClick={() => setAnalyticsKpiModalOpen(false)}
          >
            <Box
              style={{
                background:
                  'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)',
                border: '2px solid rgba(255,255,255,0.3)',
                borderRadius: '15px',
                padding: '30px',
                width: '90vw',
                maxWidth: '1200px',
                maxHeight: '90vh',
                overflow: 'auto',
                position: 'relative',
                boxShadow: '0 20px 40px rgba(0,0,0,0.5)',
              }}
              onClick={(e) => e.stopPropagation()}
            >
              {/* Modal Header */}
              <Box
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  marginBottom: '25px',
                  borderBottom: '2px solid rgba(255,255,255,0.2)',
                  paddingBottom: '15px',
                }}
              >
                <Box
                  style={{
                    fontSize: '28px',
                    fontWeight: 'bold',
                    color: '#66ffff',
                  }}
                >
                  📈 KPI DASHBOARD CONFIGURATION
                </Box>
                <Box
                  style={{
                    cursor: 'pointer',
                    fontSize: '24px',
                    opacity: 0.7,
                    transition: 'opacity 0.2s ease',
                    padding: '5px',
                    borderRadius: '5px',
                  }}
                  onClick={() => setAnalyticsKpiModalOpen(false)}
                  onMouseEnter={(e) => (e.target.style.opacity = '1')}
                  onMouseLeave={(e) => (e.target.style.opacity = '0.7')}
                >
                  ✕
                </Box>
              </Box>

              {/* Form Content */}
              <Box
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '25px',
                }}
              >
                {/* Dashboard Information Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    📈 DASHBOARD INFORMATION
                  </Box>
                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Dashboard ID *
                        </Box>
                        <input
                          type="text"
                          value={analyticsKpiFormData.dashboard_id}
                          onChange={(e) =>
                            setAnalyticsKpiFormData({
                              ...analyticsKpiFormData,
                              dashboard_id: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., KPI-2024-001, DASHBOARD-001..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Dashboard Name *
                        </Box>
                        <input
                          type="text"
                          value={analyticsKpiFormData.dashboard_name}
                          onChange={(e) =>
                            setAnalyticsKpiFormData({
                              ...analyticsKpiFormData,
                              dashboard_name: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., Executive Overview, Operations Dashboard..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>

                  <Grid>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Dashboard Type *
                        </Box>
                        <select
                          value={analyticsKpiFormData.dashboard_type}
                          onChange={(e) =>
                            setAnalyticsKpiFormData({
                              ...analyticsKpiFormData,
                              dashboard_type: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="executive">👑 Executive</option>
                          <option value="operational">⚙️ Operational</option>
                          <option value="tactical">🎯 Tactical</option>
                          <option value="strategic">🗺️ Strategic</option>
                          <option value="departmental">🏢 Departmental</option>
                          <option value="project">📋 Project</option>
                          <option value="real_time">⚡ Real-Time</option>
                          <option value="custom">🎨 Custom</option>
                        </select>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Refresh Rate
                        </Box>
                        <select
                          value={analyticsKpiFormData.refresh_rate}
                          onChange={(e) =>
                            setAnalyticsKpiFormData({
                              ...analyticsKpiFormData,
                              refresh_rate: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="real_time">⚡ Real-Time</option>
                          <option value="1_minute">⏱️ 1 Minute</option>
                          <option value="5_minutes">⏱️ 5 Minutes</option>
                          <option value="15_minutes">⏱️ 15 Minutes</option>
                          <option value="1_hour">⏰ 1 Hour</option>
                          <option value="daily">📅 Daily</option>
                          <option value="manual">🔄 Manual</option>
                        </select>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Theme
                        </Box>
                        <select
                          value={analyticsKpiFormData.display_options.theme}
                          onChange={(e) =>
                            setAnalyticsKpiFormData({
                              ...analyticsKpiFormData,
                              display_options: {
                                ...analyticsKpiFormData.display_options,
                                theme: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="dark">🌙 Dark</option>
                          <option value="light">☀️ Light</option>
                          <option value="blue">🔵 Blue</option>
                          <option value="green">🟢 Green</option>
                          <option value="purple">🟣 Purple</option>
                          <option value="custom">🎨 Custom</option>
                        </select>
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* KPI Categories Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    📊 KPI CATEGORIES
                  </Box>

                  {/* Performance KPIs */}
                  <Box style={{ marginBottom: '20px' }}>
                    <Box
                      style={{
                        fontSize: '16px',
                        fontWeight: 'bold',
                        marginBottom: '10px',
                        color: '#66ffff',
                      }}
                    >
                      📊 PERFORMANCE METRICS
                    </Box>
                    <Grid>
                      <Grid.Column size={4}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              analyticsKpiFormData.kpi_categories.performance
                                .overall_efficiency
                            }
                            onChange={(e) =>
                              setAnalyticsKpiFormData({
                                ...analyticsKpiFormData,
                                kpi_categories: {
                                  ...analyticsKpiFormData.kpi_categories,
                                  performance: {
                                    ...analyticsKpiFormData.kpi_categories
                                      .performance,
                                    overall_efficiency: e.target.checked,
                                  },
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            ⚡ Overall Efficiency
                          </span>
                        </label>
                      </Grid.Column>
                      <Grid.Column size={4}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              analyticsKpiFormData.kpi_categories.performance
                                .response_time
                            }
                            onChange={(e) =>
                              setAnalyticsKpiFormData({
                                ...analyticsKpiFormData,
                                kpi_categories: {
                                  ...analyticsKpiFormData.kpi_categories,
                                  performance: {
                                    ...analyticsKpiFormData.kpi_categories
                                      .performance,
                                    response_time: e.target.checked,
                                  },
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            ⏱️ Response Time
                          </span>
                        </label>
                      </Grid.Column>
                      <Grid.Column size={4}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              analyticsKpiFormData.kpi_categories.performance
                                .throughput
                            }
                            onChange={(e) =>
                              setAnalyticsKpiFormData({
                                ...analyticsKpiFormData,
                                kpi_categories: {
                                  ...analyticsKpiFormData.kpi_categories,
                                  performance: {
                                    ...analyticsKpiFormData.kpi_categories
                                      .performance,
                                    throughput: e.target.checked,
                                  },
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            📈 Throughput
                          </span>
                        </label>
                      </Grid.Column>
                    </Grid>
                  </Box>

                  {/* Operational KPIs */}
                  <Box style={{ marginBottom: '20px' }}>
                    <Box
                      style={{
                        fontSize: '16px',
                        fontWeight: 'bold',
                        marginBottom: '10px',
                        color: '#66ffff',
                      }}
                    >
                      ⚙️ OPERATIONAL METRICS
                    </Box>
                    <Grid>
                      <Grid.Column size={4}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              analyticsKpiFormData.kpi_categories.operational
                                .uptime
                            }
                            onChange={(e) =>
                              setAnalyticsKpiFormData({
                                ...analyticsKpiFormData,
                                kpi_categories: {
                                  ...analyticsKpiFormData.kpi_categories,
                                  operational: {
                                    ...analyticsKpiFormData.kpi_categories
                                      .operational,
                                    uptime: e.target.checked,
                                  },
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>🟢 Uptime</span>
                        </label>
                      </Grid.Column>
                      <Grid.Column size={4}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              analyticsKpiFormData.kpi_categories.operational
                                .resource_utilization
                            }
                            onChange={(e) =>
                              setAnalyticsKpiFormData({
                                ...analyticsKpiFormData,
                                kpi_categories: {
                                  ...analyticsKpiFormData.kpi_categories,
                                  operational: {
                                    ...analyticsKpiFormData.kpi_categories
                                      .operational,
                                    resource_utilization: e.target.checked,
                                  },
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            📊 Resource Utilization
                          </span>
                        </label>
                      </Grid.Column>
                      <Grid.Column size={4}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              analyticsKpiFormData.kpi_categories.operational
                                .cost_efficiency
                            }
                            onChange={(e) =>
                              setAnalyticsKpiFormData({
                                ...analyticsKpiFormData,
                                kpi_categories: {
                                  ...analyticsKpiFormData.kpi_categories,
                                  operational: {
                                    ...analyticsKpiFormData.kpi_categories
                                      .operational,
                                    cost_efficiency: e.target.checked,
                                  },
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            💰 Cost Efficiency
                          </span>
                        </label>
                      </Grid.Column>
                    </Grid>
                  </Box>

                  {/* Security KPIs */}
                  <Box style={{ marginBottom: '20px' }}>
                    <Box
                      style={{
                        fontSize: '16px',
                        fontWeight: 'bold',
                        marginBottom: '10px',
                        color: '#66ffff',
                      }}
                    >
                      🔒 SECURITY METRICS
                    </Box>
                    <Grid>
                      <Grid.Column size={4}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              analyticsKpiFormData.kpi_categories.security
                                .incident_rate
                            }
                            onChange={(e) =>
                              setAnalyticsKpiFormData({
                                ...analyticsKpiFormData,
                                kpi_categories: {
                                  ...analyticsKpiFormData.kpi_categories,
                                  security: {
                                    ...analyticsKpiFormData.kpi_categories
                                      .security,
                                    incident_rate: e.target.checked,
                                  },
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            🚨 Incident Rate
                          </span>
                        </label>
                      </Grid.Column>
                      <Grid.Column size={4}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              analyticsKpiFormData.kpi_categories.security
                                .compliance_score
                            }
                            onChange={(e) =>
                              setAnalyticsKpiFormData({
                                ...analyticsKpiFormData,
                                kpi_categories: {
                                  ...analyticsKpiFormData.kpi_categories,
                                  security: {
                                    ...analyticsKpiFormData.kpi_categories
                                      .security,
                                    compliance_score: e.target.checked,
                                  },
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            ✅ Compliance Score
                          </span>
                        </label>
                      </Grid.Column>
                      <Grid.Column size={4}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              analyticsKpiFormData.kpi_categories.security
                                .threat_level
                            }
                            onChange={(e) =>
                              setAnalyticsKpiFormData({
                                ...analyticsKpiFormData,
                                kpi_categories: {
                                  ...analyticsKpiFormData.kpi_categories,
                                  security: {
                                    ...analyticsKpiFormData.kpi_categories
                                      .security,
                                    threat_level: e.target.checked,
                                  },
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            ⚠️ Threat Level
                          </span>
                        </label>
                      </Grid.Column>
                    </Grid>
                  </Box>
                </Box>

                {/* Thresholds Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    🎯 PERFORMANCE THRESHOLDS
                  </Box>
                  <Grid>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Warning Level (%)
                        </Box>
                        <input
                          type="text"
                          value={analyticsKpiFormData.thresholds.warning_level}
                          onChange={(e) =>
                            setAnalyticsKpiFormData({
                              ...analyticsKpiFormData,
                              thresholds: {
                                ...analyticsKpiFormData.thresholds,
                                warning_level: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 75..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Critical Level (%)
                        </Box>
                        <input
                          type="text"
                          value={analyticsKpiFormData.thresholds.critical_level}
                          onChange={(e) =>
                            setAnalyticsKpiFormData({
                              ...analyticsKpiFormData,
                              thresholds: {
                                ...analyticsKpiFormData.thresholds,
                                critical_level: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 90..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Target Level (%)
                        </Box>
                        <input
                          type="text"
                          value={analyticsKpiFormData.thresholds.target_level}
                          onChange={(e) =>
                            setAnalyticsKpiFormData({
                              ...analyticsKpiFormData,
                              thresholds: {
                                ...analyticsKpiFormData.thresholds,
                                target_level: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 85..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Action Buttons */}
                <Box
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    marginTop: '20px',
                    borderTop: '2px solid rgba(255,255,255,0.2)',
                    paddingTop: '20px',
                  }}
                >
                  <Box style={{ fontSize: '14px', opacity: '0.7' }}>
                    * Required fields must be completed
                  </Box>
                  <Box style={{ display: 'flex', gap: '15px' }}>
                    <EnhancedButton
                      onClick={() => setAnalyticsKpiModalOpen(false)}
                      color="default"
                      tooltip="Cancel and close form"
                    >
                      ✕ Cancel
                    </EnhancedButton>
                    <EnhancedButton
                      color="good"
                      onClick={() => {
                        // Validate required fields
                        if (
                          !analyticsKpiFormData.dashboard_id ||
                          !analyticsKpiFormData.dashboard_name ||
                          !analyticsKpiFormData.dashboard_type
                        ) {
                          addNotification(
                            'Validation Error',
                            'Please complete all required fields',
                            'error',
                          );
                          return;
                        }

                        // Submit to backend
                        act('analytics_kpi_dashboard', {
                          dashboard_data: analyticsKpiFormData,
                        });

                        // Show success notification
                        addNotification(
                          'Success',
                          'KPI dashboard configuration saved',
                          'success',
                        );

                        // Reset form and close modal
                        setAnalyticsKpiFormData({
                          dashboard_id: '',
                          dashboard_name: '',
                          dashboard_type: 'executive',
                          kpi_categories: {
                            performance: {
                              overall_efficiency: true,
                              response_time: true,
                              throughput: true,
                              accuracy: true,
                              reliability: true,
                            },
                            operational: {
                              uptime: true,
                              maintenance_schedule: true,
                              resource_utilization: true,
                              cost_efficiency: true,
                              quality_metrics: true,
                            },
                            security: {
                              incident_rate: true,
                              response_time: true,
                              compliance_score: true,
                              threat_level: true,
                              vulnerability_status: true,
                            },
                            research: {
                              project_completion: true,
                              innovation_index: true,
                              publication_rate: true,
                              collaboration_score: true,
                              breakthrough_metrics: true,
                            },
                            personnel: {
                              productivity: true,
                              training_completion: true,
                              satisfaction_score: true,
                              retention_rate: true,
                              performance_rating: true,
                            },
                          },
                          refresh_rate: 'real_time',
                          display_options: {
                            theme: 'dark',
                            layout: 'grid',
                            animations: true,
                            interactive: true,
                            alerts: true,
                          },
                          thresholds: {
                            warning_level: '75',
                            critical_level: '90',
                            target_level: '85',
                          },
                          data_sources: [],
                          custom_widgets: [],
                          sharing_settings: {
                            public_access: false,
                            authorized_users: [],
                            export_permissions: true,
                          },
                        });
                        setAnalyticsKpiModalOpen(false);
                      }}
                      tooltip="Configure KPI dashboard"
                    >
                      📈 Configure Dashboard
                    </EnhancedButton>
                  </Box>
                </Box>
              </Box>
            </Box>
          </Box>
        )}

        {/* Security Personnel Management Modal - Global Access */}
        {securityPersonnelModalOpen && (
          <Box
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              background: 'rgba(0,0,0,0.85)',
              zIndex: 1000,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              backdropFilter: 'blur(5px)',
            }}
            onClick={() => setSecurityPersonnelModalOpen(false)}
          >
            <Box
              style={{
                background:
                  'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)',
                border: '2px solid rgba(255,255,255,0.3)',
                borderRadius: '15px',
                padding: '30px',
                width: '90vw',
                maxWidth: '1200px',
                maxHeight: '90vh',
                overflow: 'auto',
                position: 'relative',
                boxShadow: '0 20px 40px rgba(0,0,0,0.5)',
              }}
              onClick={(e) => e.stopPropagation()}
            >
              {/* Modal Header */}
              <Box
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  marginBottom: '25px',
                  borderBottom: '2px solid rgba(255,255,255,0.2)',
                  paddingBottom: '15px',
                }}
              >
                <Box
                  style={{
                    fontSize: '28px',
                    fontWeight: 'bold',
                    color: '#66ffff',
                  }}
                >
                  👥 SECURITY PERSONNEL MANAGEMENT
                </Box>
                <Box
                  style={{
                    cursor: 'pointer',
                    fontSize: '24px',
                    opacity: 0.7,
                    transition: 'opacity 0.2s ease',
                    padding: '5px',
                    borderRadius: '5px',
                  }}
                  onClick={() => setSecurityPersonnelModalOpen(false)}
                  onMouseEnter={(e) => (e.target.style.opacity = '1')}
                  onMouseLeave={(e) => (e.target.style.opacity = '0.7')}
                >
                  ✕
                </Box>
              </Box>

              {/* Form Content */}
              <Box
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '25px',
                }}
              >
                {/* Operation Information Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    👥 OPERATION INFORMATION
                  </Box>
                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Operation ID *
                        </Box>
                        <input
                          type="text"
                          value={securityPersonnelFormData.operation_id}
                          onChange={(e) =>
                            setSecurityPersonnelFormData({
                              ...securityPersonnelFormData,
                              operation_id: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., SEC-PERS-2024-001, OPS-001..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Operation Type
                        </Box>
                        <select
                          value={securityPersonnelFormData.operation_type}
                          onChange={(e) =>
                            setSecurityPersonnelFormData({
                              ...securityPersonnelFormData,
                              operation_type: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="personnel_management">
                            👥 Personnel Management
                          </option>
                          <option value="assignment_review">
                            📋 Assignment Review
                          </option>
                          <option value="performance_evaluation">
                            📊 Performance Evaluation
                          </option>
                          <option value="training_coordination">
                            🎓 Training Coordination
                          </option>
                          <option value="equipment_management">
                            🔧 Equipment Management
                          </option>
                          <option value="scheduling_management">
                            📅 Scheduling Management
                          </option>
                        </select>
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Personnel Data Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    📊 PERSONNEL DATA
                  </Box>
                  <Grid>
                    <Grid.Column size={3}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Total Personnel
                        </Box>
                        <input
                          type="text"
                          value={
                            securityPersonnelFormData.personnel_data
                              .total_personnel
                          }
                          onChange={(e) =>
                            setSecurityPersonnelFormData({
                              ...securityPersonnelFormData,
                              personnel_data: {
                                ...securityPersonnelFormData.personnel_data,
                                total_personnel: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 150..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Active Personnel
                        </Box>
                        <input
                          type="text"
                          value={
                            securityPersonnelFormData.personnel_data
                              .active_personnel
                          }
                          onChange={(e) =>
                            setSecurityPersonnelFormData({
                              ...securityPersonnelFormData,
                              personnel_data: {
                                ...securityPersonnelFormData.personnel_data,
                                active_personnel: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 120..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          On Duty
                        </Box>
                        <input
                          type="text"
                          value={
                            securityPersonnelFormData.personnel_data.on_duty
                          }
                          onChange={(e) =>
                            setSecurityPersonnelFormData({
                              ...securityPersonnelFormData,
                              personnel_data: {
                                ...securityPersonnelFormData.personnel_data,
                                on_duty: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 45..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Off Duty
                        </Box>
                        <input
                          type="text"
                          value={
                            securityPersonnelFormData.personnel_data.off_duty
                          }
                          onChange={(e) =>
                            setSecurityPersonnelFormData({
                              ...securityPersonnelFormData,
                              personnel_data: {
                                ...securityPersonnelFormData.personnel_data,
                                off_duty: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 75..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Qualifications Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    🎓 QUALIFICATIONS & TRAINING
                  </Box>
                  <Grid>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              securityPersonnelFormData.qualifications
                                .firearms_certified.length > 0
                            }
                            onChange={(e) =>
                              setSecurityPersonnelFormData({
                                ...securityPersonnelFormData,
                                qualifications: {
                                  ...securityPersonnelFormData.qualifications,
                                  firearms_certified: e.target.checked
                                    ? ['All Personnel']
                                    : [],
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            🔫 Firearms Certified
                          </span>
                        </label>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              securityPersonnelFormData.qualifications
                                .taser_certified.length > 0
                            }
                            onChange={(e) =>
                              setSecurityPersonnelFormData({
                                ...securityPersonnelFormData,
                                qualifications: {
                                  ...securityPersonnelFormData.qualifications,
                                  taser_certified: e.target.checked
                                    ? ['All Personnel']
                                    : [],
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            ⚡ Taser Certified
                          </span>
                        </label>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              securityPersonnelFormData.qualifications
                                .medical_trained.length > 0
                            }
                            onChange={(e) =>
                              setSecurityPersonnelFormData({
                                ...securityPersonnelFormData,
                                qualifications: {
                                  ...securityPersonnelFormData.qualifications,
                                  medical_trained: e.target.checked
                                    ? ['All Personnel']
                                    : [],
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            🏥 Medical Trained
                          </span>
                        </label>
                      </Box>
                    </Grid.Column>
                  </Grid>
                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              securityPersonnelFormData.qualifications
                                .tactical_trained.length > 0
                            }
                            onChange={(e) =>
                              setSecurityPersonnelFormData({
                                ...securityPersonnelFormData,
                                qualifications: {
                                  ...securityPersonnelFormData.qualifications,
                                  tactical_trained: e.target.checked
                                    ? ['All Personnel']
                                    : [],
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            🎯 Tactical Trained
                          </span>
                        </label>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              securityPersonnelFormData.qualifications
                                .investigation_trained.length > 0
                            }
                            onChange={(e) =>
                              setSecurityPersonnelFormData({
                                ...securityPersonnelFormData,
                                qualifications: {
                                  ...securityPersonnelFormData.qualifications,
                                  investigation_trained: e.target.checked
                                    ? ['All Personnel']
                                    : [],
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            🔍 Investigation Trained
                          </span>
                        </label>
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Action Buttons */}
                <Box
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    marginTop: '20px',
                    borderTop: '2px solid rgba(255,255,255,0.2)',
                    paddingTop: '20px',
                  }}
                >
                  <Box style={{ fontSize: '14px', opacity: '0.7' }}>
                    * Required fields must be completed
                  </Box>
                  <Box style={{ display: 'flex', gap: '15px' }}>
                    <EnhancedButton
                      onClick={() => setSecurityPersonnelModalOpen(false)}
                      color="default"
                      tooltip="Cancel and close form"
                    >
                      ✕ Cancel
                    </EnhancedButton>
                    <EnhancedButton
                      color="good"
                      onClick={() => {
                        // Validate required fields
                        if (!securityPersonnelFormData.operation_id) {
                          addNotification(
                            'Validation Error',
                            'Please complete all required fields',
                            'error',
                          );
                          return;
                        }

                        // Submit to backend
                        act('security_manage_personnel', {
                          personnel_data: securityPersonnelFormData,
                        });

                        // Show success notification
                        addNotification(
                          'Success',
                          'Security personnel management updated',
                          'success',
                        );

                        // Reset form and close modal
                        setSecurityPersonnelFormData({
                          operation_id: '',
                          operation_type: 'personnel_management',
                          personnel_data: {
                            total_personnel: '',
                            active_personnel: '',
                            on_duty: '',
                            off_duty: '',
                            training: '',
                            leave: '',
                            suspended: '',
                          },
                          assignments: {
                            patrol_assignments: [],
                            post_assignments: [],
                            special_assignments: [],
                            emergency_assignments: [],
                          },
                          qualifications: {
                            firearms_certified: [],
                            taser_certified: [],
                            medical_trained: [],
                            tactical_trained: [],
                            investigation_trained: [],
                          },
                          performance_metrics: {
                            response_time: '',
                            incident_resolution: '',
                            community_relations: '',
                            training_completion: '',
                            disciplinary_actions: '',
                          },
                          scheduling: {
                            shift_patterns: [],
                            overtime_hours: '',
                            vacation_requests: [],
                            sick_leave: [],
                          },
                          equipment: {
                            firearms_assigned: [],
                            body_armor: [],
                            communication_devices: [],
                            vehicles: [],
                          },
                          training_schedule: [],
                          evaluation_dates: [],
                          clearance_levels: [],
                          notes: '',
                        });
                        setSecurityPersonnelModalOpen(false);
                      }}
                      tooltip="Update security personnel management"
                    >
                      👥 Update Personnel
                    </EnhancedButton>
                  </Box>
                </Box>
              </Box>
            </Box>
          </Box>
        )}

        {/* Security Logs Modal - Global Access */}
        {securityLogsModalOpen && (
          <Box
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              background: 'rgba(0,0,0,0.85)',
              zIndex: 1000,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              backdropFilter: 'blur(5px)',
            }}
            onClick={() => setSecurityLogsModalOpen(false)}
          >
            <Box
              style={{
                background:
                  'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)',
                border: '2px solid rgba(255,255,255,0.3)',
                borderRadius: '15px',
                padding: '30px',
                width: '90vw',
                maxWidth: '1200px',
                maxHeight: '90vh',
                overflow: 'auto',
                position: 'relative',
                boxShadow: '0 20px 40px rgba(0,0,0,0.5)',
              }}
              onClick={(e) => e.stopPropagation()}
            >
              {/* Modal Header */}
              <Box
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  marginBottom: '25px',
                  borderBottom: '2px solid rgba(255,255,255,0.2)',
                  paddingBottom: '15px',
                }}
              >
                <Box
                  style={{
                    fontSize: '28px',
                    fontWeight: 'bold',
                    color: '#66ffff',
                  }}
                >
                  📋 SECURITY LOGS VIEWER
                </Box>
                <Box
                  style={{
                    cursor: 'pointer',
                    fontSize: '24px',
                    opacity: 0.7,
                    transition: 'opacity 0.2s ease',
                    padding: '5px',
                    borderRadius: '5px',
                  }}
                  onClick={() => setSecurityLogsModalOpen(false)}
                  onMouseEnter={(e) => (e.target.style.opacity = '1')}
                  onMouseLeave={(e) => (e.target.style.opacity = '0.7')}
                >
                  ✕
                </Box>
              </Box>

              {/* Form Content */}
              <Box
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '25px',
                }}
              >
                {/* Log Information Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    📋 LOG INFORMATION
                  </Box>
                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Log ID *
                        </Box>
                        <input
                          type="text"
                          value={securityLogsFormData.log_id}
                          onChange={(e) =>
                            setSecurityLogsFormData({
                              ...securityLogsFormData,
                              log_id: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., LOG-2024-001, SEC-LOG-001..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Log Type
                        </Box>
                        <select
                          value={securityLogsFormData.log_type}
                          onChange={(e) =>
                            setSecurityLogsFormData({
                              ...securityLogsFormData,
                              log_type: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="security">🔒 Security</option>
                          <option value="access">🚪 Access</option>
                          <option value="incident">🚨 Incident</option>
                          <option value="system">⚙️ System</option>
                          <option value="audit">📊 Audit</option>
                          <option value="comprehensive">
                            📋 Comprehensive
                          </option>
                        </select>
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Date Range Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    📅 DATE RANGE
                  </Box>
                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Start Date
                        </Box>
                        <input
                          type="text"
                          value={securityLogsFormData.date_range.start_date}
                          onChange={(e) =>
                            setSecurityLogsFormData({
                              ...securityLogsFormData,
                              date_range: {
                                ...securityLogsFormData.date_range,
                                start_date: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 2024-01-01..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          End Date
                        </Box>
                        <input
                          type="text"
                          value={securityLogsFormData.date_range.end_date}
                          onChange={(e) =>
                            setSecurityLogsFormData({
                              ...securityLogsFormData,
                              date_range: {
                                ...securityLogsFormData.date_range,
                                end_date: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 2024-12-31..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Log Categories Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    📊 LOG CATEGORIES
                  </Box>
                  <Grid>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              securityLogsFormData.log_categories.access_logs
                            }
                            onChange={(e) =>
                              setSecurityLogsFormData({
                                ...securityLogsFormData,
                                log_categories: {
                                  ...securityLogsFormData.log_categories,
                                  access_logs: e.target.checked,
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            🚪 Access Logs
                          </span>
                        </label>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              securityLogsFormData.log_categories.incident_logs
                            }
                            onChange={(e) =>
                              setSecurityLogsFormData({
                                ...securityLogsFormData,
                                log_categories: {
                                  ...securityLogsFormData.log_categories,
                                  incident_logs: e.target.checked,
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            🚨 Incident Logs
                          </span>
                        </label>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              securityLogsFormData.log_categories.personnel_logs
                            }
                            onChange={(e) =>
                              setSecurityLogsFormData({
                                ...securityLogsFormData,
                                log_categories: {
                                  ...securityLogsFormData.log_categories,
                                  personnel_logs: e.target.checked,
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            👥 Personnel Logs
                          </span>
                        </label>
                      </Box>
                    </Grid.Column>
                  </Grid>
                  <Grid>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              securityLogsFormData.log_categories.system_logs
                            }
                            onChange={(e) =>
                              setSecurityLogsFormData({
                                ...securityLogsFormData,
                                log_categories: {
                                  ...securityLogsFormData.log_categories,
                                  system_logs: e.target.checked,
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            ⚙️ System Logs
                          </span>
                        </label>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              securityLogsFormData.log_categories.alert_logs
                            }
                            onChange={(e) =>
                              setSecurityLogsFormData({
                                ...securityLogsFormData,
                                log_categories: {
                                  ...securityLogsFormData.log_categories,
                                  alert_logs: e.target.checked,
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            ⚠️ Alert Logs
                          </span>
                        </label>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              securityLogsFormData.log_categories
                                .maintenance_logs
                            }
                            onChange={(e) =>
                              setSecurityLogsFormData({
                                ...securityLogsFormData,
                                log_categories: {
                                  ...securityLogsFormData.log_categories,
                                  maintenance_logs: e.target.checked,
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            🔧 Maintenance Logs
                          </span>
                        </label>
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Export Options Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    📤 EXPORT OPTIONS
                  </Box>
                  <Grid>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Export Format
                        </Box>
                        <select
                          value={securityLogsFormData.export_format}
                          onChange={(e) =>
                            setSecurityLogsFormData({
                              ...securityLogsFormData,
                              export_format: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="csv">📋 CSV</option>
                          <option value="json">🔧 JSON</option>
                          <option value="xml">📄 XML</option>
                          <option value="pdf">📄 PDF</option>
                          <option value="excel">📊 Excel</option>
                        </select>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Sort By
                        </Box>
                        <select
                          value={securityLogsFormData.sort_by}
                          onChange={(e) =>
                            setSecurityLogsFormData({
                              ...securityLogsFormData,
                              sort_by: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="timestamp">⏰ Timestamp</option>
                          <option value="severity">🚨 Severity</option>
                          <option value="user">👤 User</option>
                          <option value="location">📍 Location</option>
                          <option value="type">📋 Type</option>
                        </select>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Max Results
                        </Box>
                        <input
                          type="text"
                          value={securityLogsFormData.max_results}
                          onChange={(e) =>
                            setSecurityLogsFormData({
                              ...securityLogsFormData,
                              max_results: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 1000..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Action Buttons */}
                <Box
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    marginTop: '20px',
                    borderTop: '2px solid rgba(255,255,255,0.2)',
                    paddingTop: '20px',
                  }}
                >
                  <Box style={{ fontSize: '14px', opacity: '0.7' }}>
                    * Required fields must be completed
                  </Box>
                  <Box style={{ display: 'flex', gap: '15px' }}>
                    <EnhancedButton
                      onClick={() => setSecurityLogsModalOpen(false)}
                      color="default"
                      tooltip="Cancel and close form"
                    >
                      ✕ Cancel
                    </EnhancedButton>
                    <EnhancedButton
                      color="good"
                      onClick={() => {
                        // Validate required fields
                        if (!securityLogsFormData.log_id) {
                          addNotification(
                            'Validation Error',
                            'Please complete all required fields',
                            'error',
                          );
                          return;
                        }

                        // Submit to backend
                        act('security_view_logs', {
                          logs_data: securityLogsFormData,
                        });

                        // Show success notification
                        addNotification(
                          'Success',
                          'Security logs retrieved successfully',
                          'success',
                        );

                        // Reset form and close modal
                        setSecurityLogsFormData({
                          log_id: '',
                          log_type: 'security',
                          date_range: {
                            start_date: '',
                            end_date: '',
                          },
                          log_categories: {
                            access_logs: true,
                            incident_logs: true,
                            personnel_logs: true,
                            system_logs: true,
                            alert_logs: true,
                            maintenance_logs: true,
                          },
                          filters: {
                            severity: 'all',
                            personnel: 'all',
                            location: 'all',
                            incident_type: 'all',
                          },
                          search_terms: [],
                          export_format: 'csv',
                          include_details: true,
                          include_metadata: true,
                          sort_by: 'timestamp',
                          sort_order: 'descending',
                          max_results: '1000',
                          real_time_monitoring: false,
                          alert_thresholds: {
                            critical_incidents: '5',
                            failed_access: '10',
                            system_errors: '20',
                          },
                        });
                        setSecurityLogsModalOpen(false);
                      }}
                      tooltip="Retrieve security logs"
                    >
                      📋 Retrieve Logs
                    </EnhancedButton>
                  </Box>
                </Box>
              </Box>
            </Box>
          </Box>
        )}

        {/* Security Scan Modal - Global Access */}
        {securityScanModalOpen && (
          <Box
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              background: 'rgba(0,0,0,0.85)',
              zIndex: 1000,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              backdropFilter: 'blur(5px)',
            }}
            onClick={() => setSecurityScanModalOpen(false)}
          >
            <Box
              style={{
                background:
                  'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)',
                border: '2px solid rgba(255,255,255,0.3)',
                borderRadius: '15px',
                padding: '30px',
                width: '90vw',
                maxWidth: '1200px',
                maxHeight: '90vh',
                overflow: 'auto',
                position: 'relative',
                boxShadow: '0 20px 40px rgba(0,0,0,0.5)',
              }}
              onClick={(e) => e.stopPropagation()}
            >
              {/* Modal Header */}
              <Box
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  marginBottom: '25px',
                  borderBottom: '2px solid rgba(255,255,255,0.2)',
                  paddingBottom: '15px',
                }}
              >
                <Box
                  style={{
                    fontSize: '28px',
                    fontWeight: 'bold',
                    color: '#66ffff',
                  }}
                >
                  🔍 SECURITY SCAN CONFIGURATION
                </Box>
                <Box
                  style={{
                    cursor: 'pointer',
                    fontSize: '24px',
                    opacity: 0.7,
                    transition: 'opacity 0.2s ease',
                    padding: '5px',
                    borderRadius: '5px',
                  }}
                  onClick={() => setSecurityScanModalOpen(false)}
                  onMouseEnter={(e) => (e.target.style.opacity = '1')}
                  onMouseLeave={(e) => (e.target.style.opacity = '0.7')}
                >
                  ✕
                </Box>
              </Box>

              {/* Form Content */}
              <Box
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '25px',
                }}
              >
                {/* Scan Information Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    🔍 SCAN INFORMATION
                  </Box>
                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Scan ID *
                        </Box>
                        <input
                          type="text"
                          value={securityScanFormData.scan_id}
                          onChange={(e) =>
                            setSecurityScanFormData({
                              ...securityScanFormData,
                              scan_id: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., SCAN-2024-001, SEC-SCAN-001..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Scan Type
                        </Box>
                        <select
                          value={securityScanFormData.scan_type}
                          onChange={(e) =>
                            setSecurityScanFormData({
                              ...securityScanFormData,
                              scan_type: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="comprehensive">
                            🔍 Comprehensive
                          </option>
                          <option value="quick">⚡ Quick</option>
                          <option value="deep">🕳️ Deep</option>
                          <option value="targeted">🎯 Targeted</option>
                          <option value="scheduled">📅 Scheduled</option>
                          <option value="emergency">🚨 Emergency</option>
                        </select>
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Target Systems Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    🎯 TARGET SYSTEMS
                  </Box>
                  <Grid>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              securityScanFormData.target_systems.access_control
                            }
                            onChange={(e) =>
                              setSecurityScanFormData({
                                ...securityScanFormData,
                                target_systems: {
                                  ...securityScanFormData.target_systems,
                                  access_control: e.target.checked,
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            🚪 Access Control
                          </span>
                        </label>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              securityScanFormData.target_systems.surveillance
                            }
                            onChange={(e) =>
                              setSecurityScanFormData({
                                ...securityScanFormData,
                                target_systems: {
                                  ...securityScanFormData.target_systems,
                                  surveillance: e.target.checked,
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            📹 Surveillance
                          </span>
                        </label>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              securityScanFormData.target_systems.communications
                            }
                            onChange={(e) =>
                              setSecurityScanFormData({
                                ...securityScanFormData,
                                target_systems: {
                                  ...securityScanFormData.target_systems,
                                  communications: e.target.checked,
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            📡 Communications
                          </span>
                        </label>
                      </Box>
                    </Grid.Column>
                  </Grid>
                  <Grid>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              securityScanFormData.target_systems.databases
                            }
                            onChange={(e) =>
                              setSecurityScanFormData({
                                ...securityScanFormData,
                                target_systems: {
                                  ...securityScanFormData.target_systems,
                                  databases: e.target.checked,
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>🗄️ Databases</span>
                        </label>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              securityScanFormData.target_systems.networks
                            }
                            onChange={(e) =>
                              setSecurityScanFormData({
                                ...securityScanFormData,
                                target_systems: {
                                  ...securityScanFormData.target_systems,
                                  networks: e.target.checked,
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>🌐 Networks</span>
                        </label>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={4}>
                      <Box style={{ marginBottom: '15px' }}>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              securityScanFormData.target_systems
                                .physical_security
                            }
                            onChange={(e) =>
                              setSecurityScanFormData({
                                ...securityScanFormData,
                                target_systems: {
                                  ...securityScanFormData.target_systems,
                                  physical_security: e.target.checked,
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            🏢 Physical Security
                          </span>
                        </label>
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Scan Parameters Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    ⚙️ SCAN PARAMETERS
                  </Box>
                  <Grid>
                    <Grid.Column size={3}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Scan Depth
                        </Box>
                        <select
                          value={securityScanFormData.scan_parameters.depth}
                          onChange={(e) =>
                            setSecurityScanFormData({
                              ...securityScanFormData,
                              scan_parameters: {
                                ...securityScanFormData.scan_parameters,
                                depth: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="basic">🔍 Basic</option>
                          <option value="standard">📊 Standard</option>
                          <option value="thorough">🔬 Thorough</option>
                          <option value="comprehensive">
                            📋 Comprehensive
                          </option>
                        </select>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Scan Speed
                        </Box>
                        <select
                          value={securityScanFormData.scan_parameters.speed}
                          onChange={(e) =>
                            setSecurityScanFormData({
                              ...securityScanFormData,
                              scan_parameters: {
                                ...securityScanFormData.scan_parameters,
                                speed: e.target.value,
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="slow">🐌 Slow</option>
                          <option value="balanced">⚖️ Balanced</option>
                          <option value="fast">⚡ Fast</option>
                          <option value="ultra">🚀 Ultra</option>
                        </select>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Stealth Mode
                        </Box>
                        <select
                          value={
                            securityScanFormData.scan_parameters.stealth
                              ? 'enabled'
                              : 'disabled'
                          }
                          onChange={(e) =>
                            setSecurityScanFormData({
                              ...securityScanFormData,
                              scan_parameters: {
                                ...securityScanFormData.scan_parameters,
                                stealth: e.target.value === 'enabled',
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="disabled">❌ Disabled</option>
                          <option value="enabled">✅ Enabled</option>
                        </select>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Real-time
                        </Box>
                        <select
                          value={
                            securityScanFormData.scan_parameters.real_time
                              ? 'enabled'
                              : 'disabled'
                          }
                          onChange={(e) =>
                            setSecurityScanFormData({
                              ...securityScanFormData,
                              scan_parameters: {
                                ...securityScanFormData.scan_parameters,
                                real_time: e.target.value === 'enabled',
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="disabled">❌ Disabled</option>
                          <option value="enabled">✅ Enabled</option>
                        </select>
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Action Buttons */}
                <Box
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    marginTop: '20px',
                    borderTop: '2px solid rgba(255,255,255,0.2)',
                    paddingTop: '20px',
                  }}
                >
                  <Box style={{ fontSize: '14px', opacity: '0.7' }}>
                    * Required fields must be completed
                  </Box>
                  <Box style={{ display: 'flex', gap: '15px' }}>
                    <EnhancedButton
                      onClick={() => setSecurityScanModalOpen(false)}
                      color="default"
                      tooltip="Cancel and close form"
                    >
                      ✕ Cancel
                    </EnhancedButton>
                    <EnhancedButton
                      color="good"
                      onClick={() => {
                        // Validate required fields
                        if (!securityScanFormData.scan_id) {
                          addNotification(
                            'Validation Error',
                            'Please complete all required fields',
                            'error',
                          );
                          return;
                        }

                        // Submit to backend
                        act('security_scan', {
                          scan_data: securityScanFormData,
                        });

                        // Show success notification
                        addNotification(
                          'Success',
                          'Security scan initiated successfully',
                          'success',
                        );

                        // Reset form and close modal
                        setSecurityScanFormData({
                          scan_id: '',
                          scan_type: 'comprehensive',
                          target_systems: {
                            access_control: true,
                            surveillance: true,
                            communications: true,
                            databases: true,
                            networks: true,
                            physical_security: true,
                          },
                          scan_parameters: {
                            depth: 'thorough',
                            speed: 'balanced',
                            stealth: false,
                            real_time: true,
                          },
                          vulnerability_assessment: {
                            critical_vulnerabilities: true,
                            high_priority: true,
                            medium_priority: true,
                            low_priority: false,
                            informational: false,
                          },
                          threat_detection: {
                            malware_scan: true,
                            intrusion_detection: true,
                            anomaly_detection: true,
                            behavioral_analysis: true,
                            signature_matching: true,
                          },
                          physical_security: {
                            door_integrity: true,
                            camera_systems: true,
                            alarm_systems: true,
                            environmental_monitoring: true,
                            perimeter_security: true,
                          },
                          reporting: {
                            generate_report: true,
                            alert_authorities: true,
                            log_findings: true,
                            create_tickets: true,
                          },
                          scan_schedule: {
                            immediate: true,
                            scheduled: false,
                            recurring: false,
                          },
                        });
                        setSecurityScanModalOpen(false);
                      }}
                      tooltip="Initiate security scan"
                    >
                      🔍 Start Scan
                    </EnhancedButton>
                  </Box>
                </Box>
              </Box>
            </Box>
          </Box>
        )}

        {/* Security Access Control Modal - Global Access */}
        {securityAccessModalOpen && (
          <Box
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              background: 'rgba(0,0,0,0.85)',
              zIndex: 1000,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              backdropFilter: 'blur(5px)',
            }}
            onClick={() => setSecurityAccessModalOpen(false)}
          >
            <Box
              style={{
                background:
                  'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)',
                border: '2px solid rgba(255,255,255,0.3)',
                borderRadius: '15px',
                padding: '30px',
                width: '90vw',
                maxWidth: '1200px',
                maxHeight: '90vh',
                overflow: 'auto',
                position: 'relative',
                boxShadow: '0 20px 40px rgba(0,0,0,0.5)',
              }}
              onClick={(e) => e.stopPropagation()}
            >
              {/* Modal Header */}
              <Box
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  marginBottom: '25px',
                  borderBottom: '2px solid rgba(255,255,255,0.2)',
                  paddingBottom: '15px',
                }}
              >
                <Box
                  style={{
                    fontSize: '28px',
                    fontWeight: 'bold',
                    color: '#66ffff',
                  }}
                >
                  🚪 SECURITY ACCESS CONTROL
                </Box>
                <Box
                  style={{
                    cursor: 'pointer',
                    fontSize: '24px',
                    opacity: 0.7,
                    transition: 'opacity 0.2s ease',
                    padding: '5px',
                    borderRadius: '5px',
                  }}
                  onClick={() => setSecurityAccessModalOpen(false)}
                  onMouseEnter={(e) => (e.target.style.opacity = '1')}
                  onMouseLeave={(e) => (e.target.style.opacity = '0.7')}
                >
                  ✕
                </Box>
              </Box>

              {/* Form Content */}
              <Box
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '25px',
                }}
              >
                {/* Access Information Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    🚪 ACCESS INFORMATION
                  </Box>
                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Access ID *
                        </Box>
                        <input
                          type="text"
                          value={securityAccessFormData.access_id}
                          onChange={(e) =>
                            setSecurityAccessFormData({
                              ...securityAccessFormData,
                              access_id: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., ACC-2024-001, ACCESS-001..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Access Type
                        </Box>
                        <select
                          value={securityAccessFormData.access_type}
                          onChange={(e) =>
                            setSecurityAccessFormData({
                              ...securityAccessFormData,
                              access_type: e.target.value,
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="system_management">
                            ⚙️ System Management
                          </option>
                          <option value="user_management">
                            👥 User Management
                          </option>
                          <option value="authentication">
                            🔐 Authentication
                          </option>
                          <option value="monitoring">📊 Monitoring</option>
                          <option value="emergency_protocols">
                            🚨 Emergency Protocols
                          </option>
                          <option value="comprehensive">
                            📋 Comprehensive
                          </option>
                        </select>
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Access Levels Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    🔐 ACCESS LEVELS
                  </Box>
                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '16px',
                            fontWeight: 'bold',
                            marginBottom: '10px',
                            color: '#66ffff',
                          }}
                        >
                          🔓 Level 1 - Basic Access
                        </Box>
                        <Box
                          style={{
                            fontSize: '14px',
                            opacity: 0.8,
                            marginBottom: '10px',
                          }}
                        >
                          Permissions: View logs, Basic reports, Self service
                        </Box>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              securityAccessFormData.access_levels.level_1
                                .permissions.view_logs
                            }
                            onChange={(e) =>
                              setSecurityAccessFormData({
                                ...securityAccessFormData,
                                access_levels: {
                                  ...securityAccessFormData.access_levels,
                                  level_1: {
                                    ...securityAccessFormData.access_levels
                                      .level_1,
                                    permissions: {
                                      ...securityAccessFormData.access_levels
                                        .level_1.permissions,
                                      view_logs: e.target.checked,
                                    },
                                  },
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>📋 View Logs</span>
                        </label>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '16px',
                            fontWeight: 'bold',
                            marginBottom: '10px',
                            color: '#66ffff',
                          }}
                        >
                          🔒 Level 2 - Supervisor Access
                        </Box>
                        <Box
                          style={{
                            fontSize: '14px',
                            opacity: 0.8,
                            marginBottom: '10px',
                          }}
                        >
                          Permissions: Personnel management, Incident reports,
                          Basic analytics
                        </Box>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              securityAccessFormData.access_levels.level_2
                                .permissions.personnel_management
                            }
                            onChange={(e) =>
                              setSecurityAccessFormData({
                                ...securityAccessFormData,
                                access_levels: {
                                  ...securityAccessFormData.access_levels,
                                  level_2: {
                                    ...securityAccessFormData.access_levels
                                      .level_2,
                                    permissions: {
                                      ...securityAccessFormData.access_levels
                                        .level_2.permissions,
                                      personnel_management: e.target.checked,
                                    },
                                  },
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            👥 Personnel Management
                          </span>
                        </label>
                      </Box>
                    </Grid.Column>
                  </Grid>
                  <Grid>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '16px',
                            fontWeight: 'bold',
                            marginBottom: '10px',
                            color: '#66ffff',
                          }}
                        >
                          🔐 Level 3 - Manager Access
                        </Box>
                        <Box
                          style={{
                            fontSize: '14px',
                            opacity: 0.8,
                            marginBottom: '10px',
                          }}
                        >
                          Permissions: All reports, Incident management, System
                          configuration
                        </Box>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              securityAccessFormData.access_levels.level_3
                                .permissions.system_configuration
                            }
                            onChange={(e) =>
                              setSecurityAccessFormData({
                                ...securityAccessFormData,
                                access_levels: {
                                  ...securityAccessFormData.access_levels,
                                  level_3: {
                                    ...securityAccessFormData.access_levels
                                      .level_3,
                                    permissions: {
                                      ...securityAccessFormData.access_levels
                                        .level_3.permissions,
                                      system_configuration: e.target.checked,
                                    },
                                  },
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            ⚙️ System Configuration
                          </span>
                        </label>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '16px',
                            fontWeight: 'bold',
                            marginBottom: '10px',
                            color: '#66ffff',
                          }}
                        >
                          🔐 Level 4 - Administrator Access
                        </Box>
                        <Box
                          style={{
                            fontSize: '14px',
                            opacity: 0.8,
                            marginBottom: '10px',
                          }}
                        >
                          Permissions: All permissions, Full system control
                        </Box>
                        <label
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                          }}
                        >
                          <input
                            type="checkbox"
                            checked={
                              securityAccessFormData.access_levels.level_4
                                .permissions.all_permissions
                            }
                            onChange={(e) =>
                              setSecurityAccessFormData({
                                ...securityAccessFormData,
                                access_levels: {
                                  ...securityAccessFormData.access_levels,
                                  level_4: {
                                    ...securityAccessFormData.access_levels
                                      .level_4,
                                    permissions: {
                                      ...securityAccessFormData.access_levels
                                        .level_4.permissions,
                                      all_permissions: e.target.checked,
                                    },
                                  },
                                },
                              })
                            }
                            style={{ transform: 'scale(1.2)' }}
                          />
                          <span style={{ fontSize: '14px' }}>
                            🔓 All Permissions
                          </span>
                        </label>
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Authentication Settings Section */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    🔐 AUTHENTICATION SETTINGS
                  </Box>
                  <Grid>
                    <Grid.Column size={3}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Min Password Length
                        </Box>
                        <input
                          type="text"
                          value={
                            securityAccessFormData.authentication
                              .password_policy.min_length
                          }
                          onChange={(e) =>
                            setSecurityAccessFormData({
                              ...securityAccessFormData,
                              authentication: {
                                ...securityAccessFormData.authentication,
                                password_policy: {
                                  ...securityAccessFormData.authentication
                                    .password_policy,
                                  min_length: e.target.value,
                                },
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 12..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Password Complexity
                        </Box>
                        <select
                          value={
                            securityAccessFormData.authentication
                              .password_policy.complexity
                          }
                          onChange={(e) =>
                            setSecurityAccessFormData({
                              ...securityAccessFormData,
                              authentication: {
                                ...securityAccessFormData.authentication,
                                password_policy: {
                                  ...securityAccessFormData.authentication
                                    .password_policy,
                                  complexity: e.target.value,
                                },
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                        >
                          <option value="low">🔓 Low</option>
                          <option value="medium">🔒 Medium</option>
                          <option value="high">🔐 High</option>
                          <option value="maximum">🔐 Maximum</option>
                        </select>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Expiration (Days)
                        </Box>
                        <input
                          type="text"
                          value={
                            securityAccessFormData.authentication
                              .password_policy.expiration_days
                          }
                          onChange={(e) =>
                            setSecurityAccessFormData({
                              ...securityAccessFormData,
                              authentication: {
                                ...securityAccessFormData.authentication,
                                password_policy: {
                                  ...securityAccessFormData.authentication
                                    .password_policy,
                                  expiration_days: e.target.value,
                                },
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 90..."
                        />
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Box style={{ marginBottom: '15px' }}>
                        <Box
                          style={{
                            fontSize: '14px',
                            marginBottom: '8px',
                            opacity: 0.8,
                          }}
                        >
                          Session Timeout (Min)
                        </Box>
                        <input
                          type="text"
                          value={
                            securityAccessFormData.authentication
                              .session_management.timeout_minutes
                          }
                          onChange={(e) =>
                            setSecurityAccessFormData({
                              ...securityAccessFormData,
                              authentication: {
                                ...securityAccessFormData.authentication,
                                session_management: {
                                  ...securityAccessFormData.authentication
                                    .session_management,
                                  timeout_minutes: e.target.value,
                                },
                              },
                            })
                          }
                          style={{
                            width: '100%',
                            padding: '12px',
                            background: 'rgba(255,255,255,0.1)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            borderRadius: '6px',
                            color: '#ffffff',
                            fontSize: '14px',
                          }}
                          placeholder="e.g., 30..."
                        />
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Action Buttons */}
                <Box
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    marginTop: '20px',
                    borderTop: '2px solid rgba(255,255,255,0.2)',
                    paddingTop: '20px',
                  }}
                >
                  <Box style={{ fontSize: '14px', opacity: '0.7' }}>
                    * Required fields must be completed
                  </Box>
                  <Box style={{ display: 'flex', gap: '15px' }}>
                    <EnhancedButton
                      onClick={() => setSecurityAccessModalOpen(false)}
                      color="default"
                      tooltip="Cancel and close form"
                    >
                      ✕ Cancel
                    </EnhancedButton>
                    <EnhancedButton
                      color="good"
                      onClick={() => {
                        // Validate required fields
                        if (!securityAccessFormData.access_id) {
                          addNotification(
                            'Validation Error',
                            'Please complete all required fields',
                            'error',
                          );
                          return;
                        }

                        // Submit to backend
                        act('security_access_control', {
                          access_data: securityAccessFormData,
                        });

                        // Show success notification
                        addNotification(
                          'Success',
                          'Security access control updated successfully',
                          'success',
                        );

                        // Reset form and close modal
                        setSecurityAccessFormData({
                          access_id: '',
                          access_type: 'system_management',
                          access_levels: {
                            level_1: {
                              name: 'Basic Access',
                              permissions: {
                                view_logs: true,
                                basic_reports: true,
                                self_service: true,
                              },
                              restrictions: [],
                            },
                            level_2: {
                              name: 'Supervisor Access',
                              permissions: {
                                view_logs: true,
                                basic_reports: true,
                                personnel_management: true,
                                incident_reports: true,
                                basic_analytics: true,
                              },
                              restrictions: [],
                            },
                            level_3: {
                              name: 'Manager Access',
                              permissions: {
                                view_logs: true,
                                all_reports: true,
                                personnel_management: true,
                                incident_management: true,
                                system_configuration: true,
                                analytics: true,
                              },
                              restrictions: [],
                            },
                            level_4: {
                              name: 'Administrator Access',
                              permissions: {
                                all_permissions: true,
                              },
                              restrictions: [],
                            },
                          },
                          user_management: {
                            add_users: true,
                            remove_users: true,
                            modify_permissions: true,
                            bulk_operations: true,
                          },
                          authentication: {
                            password_policy: {
                              min_length: '12',
                              complexity: 'high',
                              expiration_days: '90',
                              history_count: '5',
                            },
                            multi_factor: {
                              enabled: true,
                              methods: ['sms', 'email', 'authenticator'],
                              backup_codes: true,
                            },
                            session_management: {
                              timeout_minutes: '30',
                              concurrent_sessions: '2',
                              ip_restrictions: true,
                            },
                          },
                          access_points: {
                            doors: [],
                            elevators: [],
                            restricted_areas: [],
                            systems: [],
                            networks: [],
                          },
                          monitoring: {
                            real_time_monitoring: true,
                            access_logs: true,
                            failed_attempts: true,
                            unusual_patterns: true,
                            alerts: true,
                          },
                          emergency_protocols: {
                            lockdown_procedures: [],
                            emergency_access: [],
                            override_protocols: [],
                            backup_systems: [],
                          },
                        });
                        setSecurityAccessModalOpen(false);
                      }}
                      tooltip="Update security access control"
                    >
                      🚪 Update Access Control
                    </EnhancedButton>
                  </Box>
                </Box>
              </Box>
            </Box>
          </Box>
        )}

        {/* Budget Transaction Modal */}
        {budgetModal && (
          <Box
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              background: 'rgba(0,0,0,0.85)',
              zIndex: 1000,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              backdropFilter: 'blur(5px)',
            }}
            onClick={() => setBudgetModal(false)}
          >
            <Box
              style={{
                background:
                  'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)',
                border: '2px solid rgba(255,255,255,0.3)',
                borderRadius: '15px',
                padding: '30px',
                width: '90vw',
                maxWidth: '800px',
                maxHeight: '90vh',
                overflow: 'auto',
                position: 'relative',
                boxShadow: '0 20px 40px rgba(0,0,0,0.5)',
              }}
              onClick={(e) => e.stopPropagation()}
            >
              {/* Modal Header */}
              <Box
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  marginBottom: '25px',
                  borderBottom: '2px solid rgba(255,255,255,0.2)',
                  paddingBottom: '15px',
                }}
              >
                <Box
                  style={{
                    fontSize: '28px',
                    fontWeight: 'bold',
                    color: '#66ffff',
                  }}
                >
                  💰 ADD BUDGET TRANSACTION
                </Box>
                <Box
                  style={{
                    cursor: 'pointer',
                    fontSize: '24px',
                    opacity: 0.7,
                    transition: 'opacity 0.2s ease',
                    padding: '5px',
                    borderRadius: '5px',
                  }}
                  onClick={() => setBudgetModal(false)}
                  onMouseEnter={(e) => (e.target.style.opacity = '1')}
                  onMouseLeave={(e) => (e.target.style.opacity = '0.7')}
                >
                  ✕
                </Box>
              </Box>

              {/* Form Content */}
              <Box
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '25px',
                }}
              >
                <Grid>
                  <Grid.Column size={6}>
                    <Box style={{ marginBottom: '15px' }}>
                      <Box
                        style={{
                          fontSize: '14px',
                          marginBottom: '8px',
                          opacity: 0.8,
                        }}
                      >
                        Department *
                      </Box>
                      <select
                        value={budgetFormData.department_id}
                        onChange={(e) =>
                          setBudgetFormData({
                            ...budgetFormData,
                            department_id: e.target.value,
                          })
                        }
                        style={{
                          width: '100%',
                          padding: '12px',
                          background: 'rgba(255,255,255,0.1)',
                          border: '1px solid rgba(255,255,255,0.3)',
                          borderRadius: '6px',
                          color: '#ffffff',
                          fontSize: '14px',
                        }}
                      >
                        <option value="security">Security Department</option>
                        <option value="medical">Medical Department</option>
                        <option value="research">Research Department</option>
                        <option value="engineering">
                          Engineering Department
                        </option>
                        <option value="supply">Supply Department</option>
                        <option value="service">Service Department</option>
                        <option value="command">Command Department</option>
                      </select>
                    </Box>
                  </Grid.Column>
                  <Grid.Column size={6}>
                    <Box style={{ marginBottom: '15px' }}>
                      <Box
                        style={{
                          fontSize: '14px',
                          marginBottom: '8px',
                          opacity: 0.8,
                        }}
                      >
                        Transaction Type *
                      </Box>
                      <select
                        value={budgetFormData.transaction_type}
                        onChange={(e) =>
                          setBudgetFormData({
                            ...budgetFormData,
                            transaction_type: e.target.value,
                          })
                        }
                        style={{
                          width: '100%',
                          padding: '12px',
                          background: 'rgba(255,255,255,0.1)',
                          border: '1px solid rgba(255,255,255,0.3)',
                          borderRadius: '6px',
                          color: '#ffffff',
                          fontSize: '14px',
                        }}
                      >
                        <option value="EXPENSE">Expense</option>
                        <option value="REVENUE">Revenue</option>
                      </select>
                    </Box>
                  </Grid.Column>
                </Grid>

                <Grid>
                  <Grid.Column size={6}>
                    <Box style={{ marginBottom: '15px' }}>
                      <Box
                        style={{
                          fontSize: '14px',
                          marginBottom: '8px',
                          opacity: 0.8,
                        }}
                      >
                        Amount (Credits) *
                      </Box>
                      <input
                        type="number"
                        value={budgetFormData.amount}
                        onChange={(e) =>
                          setBudgetFormData({
                            ...budgetFormData,
                            amount: e.target.value,
                          })
                        }
                        style={{
                          width: '100%',
                          padding: '12px',
                          background: 'rgba(255,255,255,0.1)',
                          border: '1px solid rgba(255,255,255,0.3)',
                          borderRadius: '6px',
                          color: '#ffffff',
                          fontSize: '14px',
                        }}
                        placeholder="e.g., 50000"
                      />
                    </Box>
                  </Grid.Column>
                  <Grid.Column size={6}>
                    <Box style={{ marginBottom: '15px' }}>
                      <Box
                        style={{
                          fontSize: '14px',
                          marginBottom: '8px',
                          opacity: 0.8,
                        }}
                      >
                        Category *
                      </Box>
                      <select
                        value={budgetFormData.category}
                        onChange={(e) =>
                          setBudgetFormData({
                            ...budgetFormData,
                            category: e.target.value,
                          })
                        }
                        style={{
                          width: '100%',
                          padding: '12px',
                          background: 'rgba(255,255,255,0.1)',
                          border: '1px solid rgba(255,255,255,0.3)',
                          borderRadius: '6px',
                          color: '#ffffff',
                          fontSize: '14px',
                        }}
                      >
                        <option value="personnel">Personnel</option>
                        <option value="equipment">Equipment</option>
                        <option value="maintenance">Maintenance</option>
                        <option value="research">Research</option>
                        <option value="security">Security</option>
                        <option value="medical">Medical</option>
                        <option value="utilities">Utilities</option>
                        <option value="containment">Containment</option>
                        <option value="transportation">Transportation</option>
                        <option value="miscellaneous">Miscellaneous</option>
                      </select>
                    </Box>
                  </Grid.Column>
                </Grid>

                <Box style={{ marginBottom: '15px' }}>
                  <Box
                    style={{
                      fontSize: '14px',
                      marginBottom: '8px',
                      opacity: 0.8,
                    }}
                  >
                    Description *
                  </Box>
                  <textarea
                    value={budgetFormData.description}
                    onChange={(e) =>
                      setBudgetFormData({
                        ...budgetFormData,
                        description: e.target.value,
                      })
                    }
                    style={{
                      width: '100%',
                      padding: '12px',
                      background: 'rgba(255,255,255,0.1)',
                      border: '1px solid rgba(255,255,255,0.3)',
                      borderRadius: '6px',
                      color: '#ffffff',
                      fontSize: '14px',
                      minHeight: '80px',
                      resize: 'vertical',
                    }}
                    placeholder="Describe the transaction purpose and details..."
                  />
                </Box>

                {/* Action Buttons */}
                <Box
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    marginTop: '20px',
                    borderTop: '2px solid rgba(255,255,255,0.2)',
                    paddingTop: '20px',
                  }}
                >
                  <Box style={{ fontSize: '14px', opacity: '0.7' }}>
                    * Required fields must be completed
                  </Box>
                  <Box style={{ display: 'flex', gap: '15px' }}>
                    <EnhancedButton
                      onClick={() => setBudgetModal(false)}
                      color="default"
                      tooltip="Cancel and close form"
                    >
                      ✕ Cancel
                    </EnhancedButton>
                    <EnhancedButton
                      color="good"
                      onClick={() => {
                        // Validate required fields
                        if (
                          !budgetFormData.department_id ||
                          !budgetFormData.amount ||
                          !budgetFormData.description
                        ) {
                          addNotification(
                            'Validation Error',
                            'Please complete all required fields',
                            'error',
                          );
                          return;
                        }

                        // Submit to backend
                        act('budget_add_transaction', {
                          transaction_data: budgetFormData,
                        });

                        // Show success notification
                        addNotification(
                          'Success',
                          'Budget transaction added successfully',
                          'success',
                        );

                        // Reset form and close modal
                        setBudgetFormData({
                          department_id: 'supply',
                          amount: '',
                          category: 'equipment',
                          description: '',
                          transaction_type: 'EXPENSE',
                        });
                        setBudgetModal(false);
                      }}
                      tooltip="Add budget transaction"
                    >
                      💰 Add Transaction
                    </EnhancedButton>
                  </Box>
                </Box>
              </Box>
            </Box>
          </Box>
        )}

        {/* Budget Request Modal */}
        {budgetRequestModal && (
          <Box
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              background: 'rgba(0,0,0,0.85)',
              zIndex: 1000,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              backdropFilter: 'blur(5px)',
            }}
            onClick={() => setBudgetRequestModal(false)}
          >
            <Box
              style={{
                background:
                  'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)',
                border: '2px solid rgba(255,255,255,0.3)',
                borderRadius: '15px',
                padding: '30px',
                width: '90vw',
                maxWidth: '800px',
                maxHeight: '90vh',
                overflow: 'auto',
                position: 'relative',
                boxShadow: '0 20px 40px rgba(0,0,0,0.5)',
              }}
              onClick={(e) => e.stopPropagation()}
            >
              {/* Modal Header */}
              <Box
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  marginBottom: '25px',
                  borderBottom: '2px solid rgba(255,255,255,0.2)',
                  paddingBottom: '15px',
                }}
              >
                <Box
                  style={{
                    fontSize: '28px',
                    fontWeight: 'bold',
                    color: '#66ffff',
                  }}
                >
                  📋 REQUEST BUDGET INCREASE
                </Box>
                <Box
                  style={{
                    cursor: 'pointer',
                    fontSize: '24px',
                    opacity: 0.7,
                    transition: 'opacity 0.2s ease',
                    padding: '5px',
                    borderRadius: '5px',
                  }}
                  onClick={() => setBudgetRequestModal(false)}
                  onMouseEnter={(e) => (e.target.style.opacity = '1')}
                  onMouseLeave={(e) => (e.target.style.opacity = '0.7')}
                >
                  ✕
                </Box>
              </Box>

              {/* Form Content */}
              <Box
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '25px',
                }}
              >
                <Grid>
                  <Grid.Column size={6}>
                    <Box style={{ marginBottom: '15px' }}>
                      <Box
                        style={{
                          fontSize: '14px',
                          marginBottom: '8px',
                          opacity: 0.8,
                        }}
                      >
                        Department *
                      </Box>
                      <select
                        value={budgetRequestData.department_id}
                        onChange={(e) =>
                          setBudgetRequestData({
                            ...budgetRequestData,
                            department_id: e.target.value,
                          })
                        }
                        style={{
                          width: '100%',
                          padding: '12px',
                          background: 'rgba(255,255,255,0.1)',
                          border: '1px solid rgba(255,255,255,0.3)',
                          borderRadius: '6px',
                          color: '#ffffff',
                          fontSize: '14px',
                        }}
                      >
                        <option value="security">Security Department</option>
                        <option value="medical">Medical Department</option>
                        <option value="research">Research Department</option>
                        <option value="engineering">
                          Engineering Department
                        </option>
                        <option value="supply">Supply Department</option>
                        <option value="service">Service Department</option>
                        <option value="command">Command Department</option>
                      </select>
                    </Box>
                  </Grid.Column>
                  <Grid.Column size={6}>
                    <Box style={{ marginBottom: '15px' }}>
                      <Box
                        style={{
                          fontSize: '14px',
                          marginBottom: '8px',
                          opacity: 0.8,
                        }}
                      >
                        Requested Amount (Credits) *
                      </Box>
                      <input
                        type="number"
                        value={budgetRequestData.requested_amount}
                        onChange={(e) =>
                          setBudgetRequestData({
                            ...budgetRequestData,
                            requested_amount: e.target.value,
                          })
                        }
                        style={{
                          width: '100%',
                          padding: '12px',
                          background: 'rgba(255,255,255,0.1)',
                          border: '1px solid rgba(255,255,255,0.3)',
                          borderRadius: '6px',
                          color: '#ffffff',
                          fontSize: '14px',
                        }}
                        placeholder="e.g., 100000"
                      />
                    </Box>
                  </Grid.Column>
                </Grid>

                <Grid>
                  <Grid.Column size={6}>
                    <Box style={{ marginBottom: '15px' }}>
                      <Box
                        style={{
                          fontSize: '14px',
                          marginBottom: '8px',
                          opacity: 0.8,
                        }}
                      >
                        Category *
                      </Box>
                      <select
                        value={budgetRequestData.requested_category}
                        onChange={(e) =>
                          setBudgetRequestData({
                            ...budgetRequestData,
                            requested_category: e.target.value,
                          })
                        }
                        style={{
                          width: '100%',
                          padding: '12px',
                          background: 'rgba(255,255,255,0.1)',
                          border: '1px solid rgba(255,255,255,0.3)',
                          borderRadius: '6px',
                          color: '#ffffff',
                          fontSize: '14px',
                        }}
                      >
                        <option value="personnel">Personnel</option>
                        <option value="equipment">Equipment</option>
                        <option value="maintenance">Maintenance</option>
                        <option value="research">Research</option>
                        <option value="security">Security</option>
                        <option value="medical">Medical</option>
                        <option value="utilities">Utilities</option>
                        <option value="containment">Containment</option>
                        <option value="transportation">Transportation</option>
                        <option value="miscellaneous">Miscellaneous</option>
                      </select>
                    </Box>
                  </Grid.Column>
                  <Grid.Column size={6}>
                    <Box style={{ marginBottom: '15px' }}>
                      <Box
                        style={{
                          fontSize: '14px',
                          marginBottom: '8px',
                          opacity: 0.8,
                        }}
                      >
                        Priority Level *
                      </Box>
                      <select
                        value={budgetRequestData.priority}
                        onChange={(e) =>
                          setBudgetRequestData({
                            ...budgetRequestData,
                            priority: parseInt(e.target.value),
                          })
                        }
                        style={{
                          width: '100%',
                          padding: '12px',
                          background: 'rgba(255,255,255,0.1)',
                          border: '1px solid rgba(255,255,255,0.3)',
                          borderRadius: '6px',
                          color: '#ffffff',
                          fontSize: '14px',
                        }}
                      >
                        <option value={1}>1 - Low Priority</option>
                        <option value={2}>2 - Normal Priority</option>
                        <option value={3}>3 - High Priority</option>
                        <option value={4}>4 - Critical Priority</option>
                        <option value={5}>5 - Emergency Priority</option>
                      </select>
                    </Box>
                  </Grid.Column>
                </Grid>

                <Box style={{ marginBottom: '15px' }}>
                  <Box
                    style={{
                      fontSize: '14px',
                      marginBottom: '8px',
                      opacity: 0.8,
                    }}
                  >
                    Justification *
                  </Box>
                  <textarea
                    value={budgetRequestData.justification}
                    onChange={(e) =>
                      setBudgetRequestData({
                        ...budgetRequestData,
                        justification: e.target.value,
                      })
                    }
                    style={{
                      width: '100%',
                      padding: '12px',
                      background: 'rgba(255,255,255,0.1)',
                      border: '1px solid rgba(255,255,255,0.3)',
                      borderRadius: '6px',
                      color: '#ffffff',
                      fontSize: '14px',
                      minHeight: '80px',
                      resize: 'vertical',
                    }}
                    placeholder="Explain why this budget increase is needed..."
                  />
                </Box>

                {/* Action Buttons */}
                <Box
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    marginTop: '20px',
                    borderTop: '2px solid rgba(255,255,255,0.2)',
                    paddingTop: '20px',
                  }}
                >
                  <Box style={{ fontSize: '14px', opacity: '0.7' }}>
                    * Required fields must be completed
                  </Box>
                  <Box style={{ display: 'flex', gap: '15px' }}>
                    <EnhancedButton
                      onClick={() => setBudgetRequestModal(false)}
                      color="default"
                      tooltip="Cancel and close form"
                    >
                      ✕ Cancel
                    </EnhancedButton>
                    <EnhancedButton
                      color="good"
                      onClick={() => {
                        // Validate required fields
                        if (
                          !budgetRequestData.department_id ||
                          !budgetRequestData.requested_amount ||
                          !budgetRequestData.justification
                        ) {
                          addNotification(
                            'Validation Error',
                            'Please complete all required fields',
                            'error',
                          );
                          return;
                        }

                        // Submit to backend
                        act('budget_request_increase', {
                          request_data: budgetRequestData,
                        });

                        // Show success notification
                        addNotification(
                          'Success',
                          'Budget increase request submitted successfully',
                          'success',
                        );

                        // Reset form and close modal
                        setBudgetRequestData({
                          department_id: 'supply',
                          requested_amount: '',
                          requested_category: 'equipment',
                          justification: '',
                          priority: 1,
                        });
                        setBudgetRequestModal(false);
                      }}
                      tooltip="Submit budget request"
                    >
                      📋 Submit Request
                    </EnhancedButton>
                  </Box>
                </Box>
              </Box>
            </Box>
          </Box>
        )}

        {/* Budget Transfer Modal */}
        {budgetTransferModal && (
          <Box
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              background: 'rgba(0,0,0,0.85)',
              zIndex: 1000,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              backdropFilter: 'blur(5px)',
            }}
            onClick={() => setBudgetTransferModal(false)}
          >
            <Box
              style={{
                background:
                  'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)',
                border: '2px solid rgba(255,255,255,0.3)',
                borderRadius: '15px',
                padding: '30px',
                width: '90vw',
                maxWidth: '600px',
                maxHeight: '90vh',
                overflow: 'auto',
                position: 'relative',
                boxShadow: '0 20px 40px rgba(0,0,0,0.5)',
              }}
              onClick={(e) => e.stopPropagation()}
            >
              {/* Modal Header */}
              <Box
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  marginBottom: '25px',
                  borderBottom: '2px solid rgba(255,255,255,0.2)',
                  paddingBottom: '15px',
                }}
              >
                <Box
                  style={{
                    fontSize: '28px',
                    fontWeight: 'bold',
                    color: '#66ffff',
                  }}
                >
                  🔄 TRANSFER BUDGET
                </Box>
                <Box
                  style={{
                    cursor: 'pointer',
                    fontSize: '24px',
                    opacity: 0.7,
                    transition: 'opacity 0.2s ease',
                    padding: '5px',
                    borderRadius: '5px',
                  }}
                  onClick={() => setBudgetTransferModal(false)}
                  onMouseEnter={(e) => (e.target.style.opacity = '1')}
                  onMouseLeave={(e) => (e.target.style.opacity = '0.7')}
                >
                  ✕
                </Box>
              </Box>

              {/* Form Content */}
              <Box
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '25px',
                }}
              >
                <Grid>
                  <Grid.Column size={6}>
                    <Box style={{ marginBottom: '15px' }}>
                      <Box
                        style={{
                          fontSize: '14px',
                          marginBottom: '8px',
                          opacity: 0.8,
                        }}
                      >
                        From Department *
                      </Box>
                      <select
                        value={budgetTransferData.from_department}
                        onChange={(e) =>
                          setBudgetTransferData({
                            ...budgetTransferData,
                            from_department: e.target.value,
                          })
                        }
                        style={{
                          width: '100%',
                          padding: '12px',
                          background: 'rgba(255,255,255,0.1)',
                          border: '1px solid rgba(255,255,255,0.3)',
                          borderRadius: '6px',
                          color: '#ffffff',
                          fontSize: '14px',
                        }}
                      >
                        <option value="security">Security Department</option>
                        <option value="medical">Medical Department</option>
                        <option value="research">Research Department</option>
                        <option value="engineering">
                          Engineering Department
                        </option>
                        <option value="supply">Supply Department</option>
                        <option value="service">Service Department</option>
                        <option value="command">Command Department</option>
                      </select>
                    </Box>
                  </Grid.Column>
                  <Grid.Column size={6}>
                    <Box style={{ marginBottom: '15px' }}>
                      <Box
                        style={{
                          fontSize: '14px',
                          marginBottom: '8px',
                          opacity: 0.8,
                        }}
                      >
                        To Department *
                      </Box>
                      <select
                        value={budgetTransferData.to_department}
                        onChange={(e) =>
                          setBudgetTransferData({
                            ...budgetTransferData,
                            to_department: e.target.value,
                          })
                        }
                        style={{
                          width: '100%',
                          padding: '12px',
                          background: 'rgba(255,255,255,0.1)',
                          border: '1px solid rgba(255,255,255,0.3)',
                          borderRadius: '6px',
                          color: '#ffffff',
                          fontSize: '14px',
                        }}
                      >
                        <option value="security">Security Department</option>
                        <option value="medical">Medical Department</option>
                        <option value="research">Research Department</option>
                        <option value="engineering">
                          Engineering Department
                        </option>
                        <option value="supply">Supply Department</option>
                        <option value="service">Service Department</option>
                        <option value="command">Command Department</option>
                      </select>
                    </Box>
                  </Grid.Column>
                </Grid>

                <Box style={{ marginBottom: '15px' }}>
                  <Box
                    style={{
                      fontSize: '14px',
                      marginBottom: '8px',
                      opacity: 0.8,
                    }}
                  >
                    Transfer Amount (Credits) *
                  </Box>
                  <input
                    type="number"
                    value={budgetTransferData.amount}
                    onChange={(e) =>
                      setBudgetTransferData({
                        ...budgetTransferData,
                        amount: e.target.value,
                      })
                    }
                    style={{
                      width: '100%',
                      padding: '12px',
                      background: 'rgba(255,255,255,0.1)',
                      border: '1px solid rgba(255,255,255,0.3)',
                      borderRadius: '6px',
                      color: '#ffffff',
                      fontSize: '14px',
                    }}
                    placeholder="e.g., 50000"
                  />
                </Box>

                <Box style={{ marginBottom: '15px' }}>
                  <Box
                    style={{
                      fontSize: '14px',
                      marginBottom: '8px',
                      opacity: 0.8,
                    }}
                  >
                    Transfer Reason *
                  </Box>
                  <textarea
                    value={budgetTransferData.reason}
                    onChange={(e) =>
                      setBudgetTransferData({
                        ...budgetTransferData,
                        reason: e.target.value,
                      })
                    }
                    style={{
                      width: '100%',
                      padding: '12px',
                      background: 'rgba(255,255,255,0.1)',
                      border: '1px solid rgba(255,255,255,0.3)',
                      borderRadius: '6px',
                      color: '#ffffff',
                      fontSize: '14px',
                      minHeight: '80px',
                      resize: 'vertical',
                    }}
                    placeholder="Explain the reason for this budget transfer..."
                  />
                </Box>

                {/* Action Buttons */}
                <Box
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    marginTop: '20px',
                    borderTop: '2px solid rgba(255,255,255,0.2)',
                    paddingTop: '20px',
                  }}
                >
                  <Box style={{ fontSize: '14px', opacity: '0.7' }}>
                    * Required fields must be completed
                  </Box>
                  <Box style={{ display: 'flex', gap: '15px' }}>
                    <EnhancedButton
                      onClick={() => setBudgetTransferModal(false)}
                      color="default"
                      tooltip="Cancel and close form"
                    >
                      ✕ Cancel
                    </EnhancedButton>
                    <EnhancedButton
                      color="good"
                      onClick={() => {
                        // Validate required fields
                        if (
                          !budgetTransferData.from_department ||
                          !budgetTransferData.to_department ||
                          !budgetTransferData.amount ||
                          !budgetTransferData.reason
                        ) {
                          addNotification(
                            'Validation Error',
                            'Please complete all required fields',
                            'error',
                          );
                          return;
                        }

                        // Validate departments are different
                        if (
                          budgetTransferData.from_department ===
                          budgetTransferData.to_department
                        ) {
                          addNotification(
                            'Validation Error',
                            'From and To departments must be different',
                            'error',
                          );
                          return;
                        }

                        // Submit to backend
                        act('budget_transfer', {
                          transfer_data: budgetTransferData,
                        });

                        // Show success notification
                        addNotification(
                          'Success',
                          'Budget transfer completed successfully',
                          'success',
                        );

                        // Reset form and close modal
                        setBudgetTransferData({
                          from_department: 'supply',
                          to_department: 'security',
                          amount: '',
                          reason: '',
                        });
                        setBudgetTransferModal(false);
                      }}
                      tooltip="Execute budget transfer"
                    >
                      🔄 Execute Transfer
                    </EnhancedButton>
                  </Box>
                </Box>
              </Box>
            </Box>
          </Box>
        )}

        {/* Budget Report Modal */}
        {budgetReportModal && (
          <Box
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              background: 'rgba(0,0,0,0.85)',
              zIndex: 1000,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              backdropFilter: 'blur(5px)',
            }}
            onClick={() => setBudgetReportModal(false)}
          >
            <Box
              style={{
                background:
                  'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)',
                border: '2px solid rgba(255,255,255,0.3)',
                borderRadius: '15px',
                padding: '30px',
                width: '90vw',
                maxWidth: '1000px',
                maxHeight: '90vh',
                overflow: 'auto',
                position: 'relative',
                boxShadow: '0 20px 40px rgba(0,0,0,0.5)',
              }}
              onClick={(e) => e.stopPropagation()}
            >
              {/* Modal Header */}
              <Box
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  marginBottom: '25px',
                  borderBottom: '2px solid rgba(255,255,255,0.2)',
                  paddingBottom: '15px',
                }}
              >
                <Box
                  style={{
                    fontSize: '28px',
                    fontWeight: 'bold',
                    color: '#66ffff',
                  }}
                >
                  📊 BUDGET ANALYSIS REPORT
                </Box>
                <Box
                  style={{
                    cursor: 'pointer',
                    fontSize: '24px',
                    opacity: 0.7,
                    transition: 'opacity 0.2s ease',
                    padding: '5px',
                    borderRadius: '5px',
                  }}
                  onClick={() => setBudgetReportModal(false)}
                  onMouseEnter={(e) => (e.target.style.opacity = '1')}
                  onMouseLeave={(e) => (e.target.style.opacity = '0.7')}
                >
                  ✕
                </Box>
              </Box>

              {/* Report Content */}
              <Box
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '25px',
                }}
              >
                {/* Executive Summary */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    📈 EXECUTIVE SUMMARY
                  </Box>
                  <Grid>
                    <Grid.Column size={3}>
                      <Box
                        style={{
                          background: 'rgba(0,255,0,0.1)',
                          padding: '15px',
                          borderRadius: '5px',
                          textAlign: 'center',
                        }}
                      >
                        <Box
                          style={{
                            fontSize: '16px',
                            fontWeight: 'bold',
                            color: '#66ff66',
                          }}
                        >
                          Total Budget
                        </Box>
                        <Box style={{ fontSize: '24px' }}>
                          ${(budget_data?.total_budget || 0).toLocaleString()}
                        </Box>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Box
                        style={{
                          background: 'rgba(255,165,0,0.1)',
                          padding: '15px',
                          borderRadius: '5px',
                          textAlign: 'center',
                        }}
                      >
                        <Box
                          style={{
                            fontSize: '16px',
                            fontWeight: 'bold',
                            color: '#ffaa66',
                          }}
                        >
                          Available
                        </Box>
                        <Box style={{ fontSize: '24px' }}>
                          $
                          {(budget_data?.current_balance || 0).toLocaleString()}
                        </Box>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Box
                        style={{
                          background: 'rgba(255,0,0,0.1)',
                          padding: '15px',
                          borderRadius: '5px',
                          textAlign: 'center',
                        }}
                      >
                        <Box
                          style={{
                            fontSize: '16px',
                            fontWeight: 'bold',
                            color: '#ff6666',
                          }}
                        >
                          Spent
                        </Box>
                        <Box style={{ fontSize: '24px' }}>
                          $
                          {(
                            (budget_data?.total_budget || 0) -
                            (budget_data?.current_balance || 0)
                          ).toLocaleString()}
                        </Box>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={3}>
                      <Box
                        style={{
                          background: 'rgba(0,255,255,0.1)',
                          padding: '15px',
                          borderRadius: '5px',
                          textAlign: 'center',
                        }}
                      >
                        <Box
                          style={{
                            fontSize: '16px',
                            fontWeight: 'bold',
                            color: '#66ffff',
                          }}
                        >
                          Utilization
                        </Box>
                        <Box style={{ fontSize: '24px' }}>
                          {budget_data?.total_budget
                            ? Math.round(
                                ((budget_data.total_budget -
                                  budget_data.current_balance) /
                                  budget_data.total_budget) *
                                  100,
                              )
                            : 0}
                          %
                        </Box>
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Department Performance */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    🏢 DEPARTMENT PERFORMANCE
                  </Box>
                  <Box
                    style={{
                      maxHeight: '300px',
                      overflowY: 'auto',
                    }}
                  >
                    {budget_data?.departments &&
                      Object.entries(budget_data.departments).map(
                        ([deptId, dept]) => (
                          <Box
                            key={deptId}
                            style={{
                              padding: '15px',
                              borderBottom: '1px solid rgba(255,255,255,0.1)',
                              marginBottom: '10px',
                            }}
                          >
                            <Box
                              style={{
                                display: 'flex',
                                justifyContent: 'space-between',
                                alignItems: 'center',
                                marginBottom: '10px',
                              }}
                            >
                              <Box
                                style={{ fontSize: '16px', fontWeight: 'bold' }}
                              >
                                {dept.name}
                              </Box>
                              <Box
                                style={{
                                  padding: '4px 8px',
                                  borderRadius: '4px',
                                  fontSize: '12px',
                                  fontWeight: 'bold',
                                  color:
                                    dept.status === 'NORMAL'
                                      ? '#66ff66'
                                      : dept.status === 'WARNING'
                                        ? '#ffff00'
                                        : dept.status === 'CRITICAL'
                                          ? '#ff6600'
                                          : '#ff0000',
                                  background:
                                    dept.status === 'NORMAL'
                                      ? 'rgba(0,255,0,0.2)'
                                      : dept.status === 'WARNING'
                                        ? 'rgba(255,255,0,0.2)'
                                        : dept.status === 'CRITICAL'
                                          ? 'rgba(255,102,0,0.2)'
                                          : 'rgba(255,0,0,0.2)',
                                }}
                              >
                                {dept.status}
                              </Box>
                            </Box>
                            <Grid>
                              <Grid.Column size={3}>
                                <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                                  Allocated
                                </Box>
                                <Box
                                  style={{
                                    fontSize: '14px',
                                    fontWeight: 'bold',
                                  }}
                                >
                                  ${dept.allocated?.toLocaleString() || 0}
                                </Box>
                              </Grid.Column>
                              <Grid.Column size={3}>
                                <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                                  Spent
                                </Box>
                                <Box
                                  style={{
                                    fontSize: '14px',
                                    fontWeight: 'bold',
                                    color: '#ff6666',
                                  }}
                                >
                                  ${dept.spent?.toLocaleString() || 0}
                                </Box>
                              </Grid.Column>
                              <Grid.Column size={3}>
                                <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                                  Remaining
                                </Box>
                                <Box
                                  style={{
                                    fontSize: '14px',
                                    fontWeight: 'bold',
                                    color: '#66ff66',
                                  }}
                                >
                                  ${dept.remaining?.toLocaleString() || 0}
                                </Box>
                              </Grid.Column>
                              <Grid.Column size={3}>
                                <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                                  Efficiency
                                </Box>
                                <Box
                                  style={{
                                    fontSize: '14px',
                                    fontWeight: 'bold',
                                    color: '#66ffff',
                                  }}
                                >
                                  {dept.efficiency || 0}%
                                </Box>
                              </Grid.Column>
                            </Grid>
                          </Box>
                        ),
                      )}
                  </Box>
                </Box>

                {/* Financial Trends */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    📊 FINANCIAL TRENDS
                  </Box>
                  <Grid>
                    <Grid.Column size={6}>
                      <Box
                        style={{
                          background: 'rgba(255,0,0,0.1)',
                          padding: '15px',
                          borderRadius: '5px',
                          marginBottom: '10px',
                        }}
                      >
                        <Box
                          style={{
                            fontSize: '16px',
                            fontWeight: 'bold',
                            color: '#ff6666',
                          }}
                        >
                          Monthly Expenses
                        </Box>
                        <Box style={{ fontSize: '20px' }}>
                          $
                          {(
                            budget_data?.monthly_expenses || 0
                          ).toLocaleString()}
                        </Box>
                        <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                          Average daily: $
                          {Math.round(
                            (budget_data?.monthly_expenses || 0) / 30,
                          ).toLocaleString()}
                        </Box>
                      </Box>
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Box
                        style={{
                          background: 'rgba(0,255,255,0.1)',
                          padding: '15px',
                          borderRadius: '5px',
                          marginBottom: '10px',
                        }}
                      >
                        <Box
                          style={{
                            fontSize: '16px',
                            fontWeight: 'bold',
                            color: '#66ffff',
                          }}
                        >
                          Monthly Revenue
                        </Box>
                        <Box style={{ fontSize: '20px' }}>
                          $
                          {(budget_data?.monthly_revenue || 0).toLocaleString()}
                        </Box>
                        <Box style={{ fontSize: '12px', opacity: 0.8 }}>
                          Net: $
                          {(
                            (budget_data?.monthly_revenue || 0) -
                            (budget_data?.monthly_expenses || 0)
                          ).toLocaleString()}
                        </Box>
                      </Box>
                    </Grid.Column>
                  </Grid>
                </Box>

                {/* Budget Trends */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    📈 BUDGET TRENDS
                  </Box>
                  <Box style={{ fontSize: '14px', lineHeight: '1.6' }}>
                    {(() => {
                      const trends = budget_data?.budget_trends || {};
                      const trendsList = [];

                      if (trends.spending_rate !== undefined) {
                        trendsList.push(
                          `💰 Daily Spending Rate: ${Math.round(trends.spending_rate).toLocaleString()} credits/day`,
                        );
                        trendsList.push(
                          `📊 Projected Monthly: ${Math.round(trends.projected_monthly).toLocaleString()} credits/month`,
                        );
                        trendsList.push(
                          `⏰ Budget Life Expectancy: ${Math.round(trends.budget_life_expectancy)} days`,
                        );
                      }

                      if (trends.department_trends) {
                        Object.entries(trends.department_trends).forEach(
                          ([deptId, deptTrends]) => {
                            trendsList.push(
                              `🏢 ${deptId.toUpperCase()}: ${Math.round(deptTrends.spending_rate).toLocaleString()} credits/day`,
                            );
                          },
                        );
                      }

                      if (trendsList.length === 0) {
                        trendsList.push(
                          '📊 Insufficient historical data for trend analysis',
                        );
                      }

                      return trendsList.map((trend, index) => (
                        <Box
                          key={index}
                          style={{
                            marginBottom: '8px',
                            padding: '6px',
                            background: 'rgba(255,255,255,0.05)',
                            borderRadius: '4px',
                          }}
                        >
                          {trend}
                        </Box>
                      ));
                    })()}
                  </Box>
                </Box>

                {/* Recommendations */}
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid rgba(255,255,255,0.1)',
                    borderRadius: '10px',
                    padding: '20px',
                  }}
                >
                  <Box
                    style={{
                      fontSize: '20px',
                      fontWeight: 'bold',
                      marginBottom: '15px',
                      color: '#66ffff',
                    }}
                  >
                    💡 RECOMMENDATIONS
                  </Box>
                  <Box style={{ fontSize: '14px', lineHeight: '1.6' }}>
                    {(() => {
                      const recommendations = [];
                      const utilization = budget_data?.total_budget
                        ? ((budget_data.total_budget -
                            budget_data.current_balance) /
                            budget_data.total_budget) *
                          100
                        : 0;

                      if (utilization > 90) {
                        recommendations.push(
                          '🚨 CRITICAL: Budget utilization is over 90%. Consider requesting additional funding.',
                        );
                      } else if (utilization > 75) {
                        recommendations.push(
                          '⚠️ WARNING: Budget utilization is over 75%. Monitor spending closely.',
                        );
                      }

                      if (
                        (budget_data?.monthly_expenses || 0) >
                        (budget_data?.monthly_revenue || 0)
                      ) {
                        recommendations.push(
                          '📉 REVENUE: Monthly expenses exceed revenue. Focus on cost reduction or revenue generation.',
                        );
                      }

                      const criticalDepts = budget_data?.departments
                        ? Object.values(budget_data.departments).filter(
                            (dept) =>
                              dept.status === 'CRITICAL' ||
                              dept.status === 'OVERSPENT',
                          )
                        : [];
                      if (criticalDepts.length > 0) {
                        recommendations.push(
                          `🔴 DEPARTMENTS: ${criticalDepts.length} department(s) have critical budget status. Immediate attention required.`,
                        );
                      }

                      if (recommendations.length === 0) {
                        recommendations.push(
                          '✅ BUDGET HEALTH: All departments are operating within normal budget parameters.',
                        );
                      }

                      return recommendations.map((rec, index) => (
                        <Box
                          key={index}
                          style={{
                            marginBottom: '10px',
                            padding: '8px',
                            background: 'rgba(255,255,255,0.05)',
                            borderRadius: '4px',
                          }}
                        >
                          {rec}
                        </Box>
                      ));
                    })()}
                  </Box>
                </Box>

                {/* Action Buttons */}
                <Box
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    marginTop: '20px',
                    borderTop: '2px solid rgba(255,255,255,0.2)',
                    paddingTop: '20px',
                  }}
                >
                  <Box style={{ fontSize: '14px', opacity: '0.7' }}>
                    Report generated on {new Date().toLocaleString()}
                  </Box>
                  <Box style={{ display: 'flex', gap: '15px' }}>
                    <EnhancedButton
                      onClick={() => setBudgetReportModal(false)}
                      color="default"
                      tooltip="Close report"
                    >
                      ✕ Close
                    </EnhancedButton>
                    <EnhancedButton
                      color="purple"
                      onClick={() => {
                        addNotification(
                          'Report Export',
                          'Budget report exported to system logs',
                          'info',
                        );
                      }}
                      tooltip="Export report to system"
                    >
                      📄 Export Report
                    </EnhancedButton>
                  </Box>
                </Box>
              </Box>
            </Box>
          </Box>
        )}

        <style>
          {`
            @keyframes blink {
              0%, 50% { opacity: 1; }
              51%, 100% { opacity: 0; }
            }
            @keyframes rotate {
              from { transform: translate(-50%, -50%) rotate(0deg); }
              to { transform: translate(-50%, -50%) rotate(360deg); }
            }
            /* Custom scrollbar styling */
            ::-webkit-scrollbar {
              width: 12px;
            }
            ::-webkit-scrollbar-track {
              background: rgba(0,0,0,0.3);
              border-radius: 6px;
            }
            ::-webkit-scrollbar-thumb {
              background: rgba(255,255,255,0.3);
              border-radius: 6px;
              border: 2px solid rgba(0,0,0,0.3);
            }
            ::-webkit-scrollbar-thumb:hover {
              background: rgba(255,255,255,0.5);
            }
            ::-webkit-scrollbar-corner {
              background: rgba(0,0,0,0.3);
            }
            /* Scrollable content areas */
            .scrollable-content {
              max-height: 400px;
              overflow-y: auto;
              padding-right: 10px;
            }
            .scrollable-table {
              max-height: 300px;
              overflow-y: auto;
            }
            .scrollable-list {
              max-height: 250px;
              overflow-y: auto;
            }
          `}
        </style>
      </Window.Content>
    </Window>
  );
};
