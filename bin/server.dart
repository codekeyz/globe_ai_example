import 'dart:convert';
import 'dart:io';

import 'package:globe_ai/globe_ai.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

final _router = Router()
  ..get('/', (req) => Response.ok('Welcome to the Globe AI Example Server!'))
  ..post('/generateText', _generateText)
  ..post('/streamText', _streamText);

Future<Response> _generateText(Request req) async {
  final body = safeParseJson<Map<dynamic, dynamic>>(await req.readAsString());

  final prompt = body['prompt'] as String;
  final model = body['model'] as String;
  final user = body['user'] as String?;

  final result = await generateText(
    model: openai.chat(model, user: user),
    prompt: prompt,
  );

  return Response.ok(
    result,
    headers: {
      HttpHeaders.contentTypeHeader: ContentType.text.mimeType,
    },
  );
}

Future<Response> _streamText(Request req) async {
  final body = safeParseJson<Map<dynamic, dynamic>>(await req.readAsString());

  final prompt = body['prompt'] as String;
  final model = body['model'] as String;
  final user = body['user'] as String?;

  final result = streamText(
    model: openai.chat(model, user: user),
    prompt: prompt,
  ).map(utf8.encode);

  return Response.ok(
    result,
    headers: {
      HttpHeaders.contentTypeHeader: ContentType.text.mimeType,
    },
  );
}

void main(List<String> args) async {
  final ip = InternetAddress.anyIPv4;

  final handler = Pipeline().addHandler(_router.call);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);

  print('Server listening on port ${server.port}');
}

T safeParseJson<T>(String jsonString) {
  try {
    return jsonDecode(jsonString) as T;
  } catch (e) {
    rethrow;
  }
}
