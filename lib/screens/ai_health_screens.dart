import 'package:flutter/material.dart';
import 'package:medisimbio_ui/models/ai_intake.dart';
import 'package:medisimbio_ui/services/ai_health_service.dart';
import 'package:medisimbio_ui/services/firebase_service.dart';

/// 4.1 START INTAKE SCREEN
class AiHealthStartScreen extends StatefulWidget {
  const AiHealthStartScreen({super.key});

  @override
  State<AiHealthStartScreen> createState() => _AiHealthStartScreenState();
}

class _AiHealthStartScreenState extends State<AiHealthStartScreen> {
  final TextEditingController _inputController = TextEditingController();
  String _selectedMode = 'Type'; // 'Type' or 'Speak'

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _startIntake() {
    final initialText = _inputController.text.trim();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AiIntakeQuestionsScreen(initialSymptom: initialText),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'AI Health Assistant',
          style:
              TextStyle(color: Color(0xFF173330), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.purple.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.psychology, color: Colors.purple, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'AI Triage & Intake',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'How can I help you today?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173330),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Describe your health concern or symptoms. Our AI assistant will ask a few clarifying questions.',
                style: TextStyle(fontSize: 14, color: Color(0xFF5A716E)),
              ),

              const SizedBox(height: 24),

              // Interaction Mode Selector (Type vs Speak)
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMode = 'Type'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _selectedMode == 'Type'
                              ? Colors.purple
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _selectedMode == 'Type'
                                ? Colors.purple
                                : const Color(0xFFD9E4E1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.keyboard_outlined,
                              color: _selectedMode == 'Type'
                                  ? Colors.white
                                  : const Color(0xFF5A716E),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Type Symptoms',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _selectedMode == 'Type'
                                    ? Colors.white
                                    : const Color(0xFF173330),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMode = 'Speak'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _selectedMode == 'Speak'
                              ? Colors.purple
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _selectedMode == 'Speak'
                                ? Colors.purple
                                : const Color(0xFFD9E4E1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.mic_none_outlined,
                              color: _selectedMode == 'Speak'
                                  ? Colors.white
                                  : const Color(0xFF5A716E),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Voice Assistant',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _selectedMode == 'Speak'
                                    ? Colors.white
                                    : const Color(0xFF173330),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Input Box / Voice Interaction Box
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (_selectedMode == 'Type') ...[
                        TextField(
                          controller: _inputController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText:
                                'e.g. I have had a high fever and headache since yesterday morning...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  const BorderSide(color: Color(0xFFD9E4E1)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  const BorderSide(color: Color(0xFFD9E4E1)),
                            ),
                          ),
                        ),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFD9E4E1)),
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: Colors.purple.withAlpha(30),
                                child: const Icon(Icons.mic,
                                    size: 36, color: Colors.purple),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Tap mic to speak your symptoms',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF173330),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Voice input will be transcribed automatically.',
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFF5A716E)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Start Intake Action Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _startIntake,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Start Intake Questions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 4.2 AI QUESTIONS SCREEN
class AiIntakeQuestionsScreen extends StatefulWidget {
  final String initialSymptom;

  const AiIntakeQuestionsScreen({super.key, this.initialSymptom = ''});

  @override
  State<AiIntakeQuestionsScreen> createState() =>
      _AiIntakeQuestionsScreenState();
}

class _AiIntakeQuestionsScreenState extends State<AiIntakeQuestionsScreen> {
  int _currentStepIndex = 0;

  final List<AiQuestion> _questions = [
    AiQuestion(
      id: 'q1',
      questionText: 'What is your primary medical concern?',
      subtitle: 'Select the main symptom you are experiencing',
      options: [
        'Fever & Chills',
        'Headache & Migraine',
        'Cough & Cold',
        'Body Pain / Fatigue'
      ],
    ),
    AiQuestion(
      id: 'q2',
      questionText: 'Since when are you experiencing this?',
      subtitle: 'Choose the duration of symptoms',
      options: ['1 day', '2-3 days', '4-7 days', 'More than 7 days'],
    ),
    AiQuestion(
      id: 'q3',
      questionText: 'Are there any associated symptoms?',
      subtitle: 'Select any accompanying issues',
      options: ['Nausea & Vomiting', 'Sore Throat', 'Loss of Appetite', 'None'],
    ),
    AiQuestion(
      id: 'q4',
      questionText: 'How severe are your symptoms?',
      subtitle: 'Rate the intensity level',
      options: ['Mild', 'Moderate', 'Severe'],
    ),
  ];

  // Session state maintained during back/next navigation
  final Map<int, String> _selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    // Default initial answer if provided
    if (widget.initialSymptom.isNotEmpty) {
      _selectedAnswers[0] = widget.initialSymptom;
    }
  }

  void _onOptionSelected(String option) {
    setState(() {
      _selectedAnswers[_currentStepIndex] = option;
    });
  }

  void _nextStep() {
    if (!_selectedAnswers.containsKey(_currentStepIndex) ||
        _selectedAnswers[_currentStepIndex]!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an option before continuing.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_currentStepIndex < _questions.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
    } else {
      // Proceed to Summary
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AiIntakeSummaryScreen(
            chiefComplaint: _selectedAnswers[0] ?? 'Fever & Chills',
            duration: _selectedAnswers[1] ?? '2-3 days',
            associatedSymptoms: _selectedAnswers[2] ?? 'None',
            severity: _selectedAnswers[3] ?? 'Moderate',
          ),
        ),
      );
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentStepIndex];
    final selectedOption = _selectedAnswers[_currentStepIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: Text(
          'Question ${_currentStepIndex + 1} of ${_questions.length}',
          style: const TextStyle(
            color: Color(0xFF173330),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF173330)),
          onPressed: _previousStep,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Indicator
              LinearProgressIndicator(
                value: (_currentStepIndex + 1) / _questions.length,
                backgroundColor: const Color(0xFFE2EEEA),
                color: Colors.purple,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),

              const SizedBox(height: 24),

              const Text(
                'Let me understand better',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                currentQuestion.questionText,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173330),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currentQuestion.subtitle,
                style: const TextStyle(fontSize: 13, color: Color(0xFF5A716E)),
              ),

              const SizedBox(height: 24),

              // Options list
              Expanded(
                child: ListView.separated(
                  itemCount: currentQuestion.options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final option = currentQuestion.options[index];
                    final isSelected = selectedOption == option;

                    return InkWell(
                      onTap: () => _onOptionSelected(option),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.purple.withAlpha(20)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.purple
                                : const Color(0xFFD9E4E1),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              option,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: const Color(0xFF173330),
                              ),
                            ),
                            Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: isSelected
                                  ? Colors.purple
                                  : const Color(0xFF8C9E9A),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Bottom Navigation (Back / Next)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFD9E4E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF173330),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: Text(
                        _currentStepIndex == _questions.length - 1
                            ? 'Review Summary'
                            : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 4.3 AI SUMMARY SCREEN
class AiIntakeSummaryScreen extends StatefulWidget {
  final String chiefComplaint;
  final String duration;
  final String associatedSymptoms;
  final String severity;

  const AiIntakeSummaryScreen({
    super.key,
    required this.chiefComplaint,
    required this.duration,
    required this.associatedSymptoms,
    required this.severity,
  });

  @override
  State<AiIntakeSummaryScreen> createState() => _AiIntakeSummaryScreenState();
}

class _AiIntakeSummaryScreenState extends State<AiIntakeSummaryScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final AiHealthService _aiHealthService = AiHealthService();

  bool _isSaving = false;

  Future<void> _confirmAndSave() async {
    final user = _firebaseService.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      final record = AiIntakeRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        uid: user.uid,
        chiefComplaint: widget.chiefComplaint,
        duration: widget.duration,
        associatedSymptoms: widget.associatedSymptoms,
        severity: widget.severity,
        createdAt: DateTime.now(),
      );

      await _aiHealthService.saveIntakeRecord(record);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI Intake Record confirmed & saved!'),
          backgroundColor: Colors.purple,
        ),
      );

      // Return to Dashboard or navigate to Care
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving AI Intake: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFA),
      appBar: AppBar(
        title: const Text(
          'AI Intake Summary',
          style:
              TextStyle(color: Color(0xFF173330), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF173330)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Distinction Banner (Crucial Requirement: AI != Doctor Diagnosis)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade900),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'AI Structured Intake — Pending Clinician Verification',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Here is what I understood',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173330),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Please review your structured symptoms before saving.',
                style: TextStyle(fontSize: 13, color: Color(0xFF5A716E)),
              ),

              const SizedBox(height: 24),

              // Summary Card derived from ACTUAL user choices
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2EEEA)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(6),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Main Concern', widget.chiefComplaint,
                        Icons.sick_outlined),
                    const Divider(height: 24),
                    _buildSummaryRow(
                        'Duration', widget.duration, Icons.timer_outlined),
                    const Divider(height: 24),
                    _buildSummaryRow('Associated Symptoms',
                        widget.associatedSymptoms, Icons.healing_outlined),
                    const Divider(height: 24),
                    _buildSummaryRow('Severity', widget.severity,
                        Icons.warning_amber_outlined),
                  ],
                ),
              ),

              const Spacer(),

              // Confirm and Save Action Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _confirmAndSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Confirm & Save Intake',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.purple, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF5A716E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173330),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
