import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

// Model for form component
class FormComponent {
  String label;
  String infoText;
  bool required;
  bool readonly;
  bool hidden;

  FormComponent({
    this.label = '',
    this.infoText = '',
    this.required = false,
    this.readonly = false,
    this.hidden = false,
  });
}

// Service to manage form components
class FormComponentService extends ChangeNotifier {
  List<FormComponent> components = [FormComponent()];

  void addComponent() {
    components.add(FormComponent());
    notifyListeners();
  }

  void removeComponent(int index) {
    if (components.length > 1) {
      components.removeAt(index);
      notifyListeners();
    }
  }
}

// Setup GetIt for dependency injection
final GetIt getIt = GetIt.instance;

void setupLocator() {
  getIt.registerSingleton<FormComponentService>(FormComponentService());
}

void main() {
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Watermeter Form',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => getIt<FormComponentService>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Watermeter Quarterly Check'),
          actions: [
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                _showFormData(context);
              },
            ),
          ],
        ),
        body: Consumer<FormComponentService>(
          builder: (context, service, child) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: service.components.length + 1,
                    itemBuilder: (context, index) {
                      if (index == service.components.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: service.addComponent,
                              child: Text('ADD'),
                            ),
                          ),
                        );
                      }
                      return FormComponentWidget(
                        key: ValueKey(service.components[index]),
                        index: index,
                        component: service.components[index],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showFormData(BuildContext context) {
    final service = getIt<FormComponentService>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: service.components.map((component) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Component:\nLabel: ${component.label}\nInfo-Text: ${component.infoText}\nSettings: ${_formatSettings(component)}',
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  String _formatSettings(FormComponent component) {
    List<String> settings = [];
    if (component.required) settings.add('Required');
    if (component.readonly) settings.add('Readonly');
    if (component.hidden) settings.add('Hidden');
    return settings.join(', ');
  }
}

class FormComponentWidget extends StatelessWidget {
  final int index;
  final FormComponent component;

  FormComponentWidget({
    required Key key,
    required this.index,
    required this.component,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = getIt<FormComponentService>();
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: component.label,
              decoration: InputDecoration(
                labelText: 'Label',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.blue[50],
                contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
              ),
              onChanged: (value) => component.label = value,
            ),
            SizedBox(height: 10.0),
            TextFormField(
              initialValue: component.infoText,
              decoration: InputDecoration(
                labelText: 'Info-Text',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.blue[50],
                contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
              ),
              onChanged: (value) => component.infoText = value,
            ),
            SizedBox(height: 10.0),
            Row(
              children: [
                Checkbox(
                  value: component.required,
                  onChanged: (value) {
                    component.required = value ?? false;
                    service.notifyListeners();
                  },
                ),
                Text('Required'),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: component.readonly,
                  onChanged: (value) {
                    component.readonly = value ?? false;
                    service.notifyListeners();
                  },
                ),
                Text('Readonly'),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: component.hidden,
                  onChanged: (value) {
                    component.hidden = value ?? false;
                    service.notifyListeners();
                  },
                ),
                Text('Hidden'),
              ],
            ),
            if (service.components.length > 1)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => service.removeComponent(index),
                  child: Text('Remove'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
