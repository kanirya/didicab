import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart';

class AccessTokenFirebase {
  static String firebaseMessagingScope =
      "https://www.googleapis.com/auth/firebase.messaging";

  Future<String> getAccessToken() async {
    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson(
        {
          "type": "service_account",
          "project_id": "didi-auth",
          "private_key_id": "5dcf31620bf18308780df926ee639170909ac5f8",
          "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQClC14NgjhPY/Ns\nRmsMU45iS1CWHVTWVyJSNuVzHYp4HtXswofaSP9B5WGEYFmDv+wQJ77J1jPqVmLU\nFlIfgdegHFbMH8VyJwHs46z5RwJ6IpzqM8vtdy2gInYxWl1h6bIUv7cCkZzHnzc8\nnx4lusSF2Zx+iVR1fbYGVlENU9MELG38Tt1LO3n/5yt/EP8Nb6lOElndBOKo+MKc\ntI0/AH77pQifTcvLt91NQV/nlo8zPw+FbvK8dPgbg0QKXn3TOPQLf6p41eXAncD8\nU4Utoqo9xu0UeHgiO4JYxtntHLX03kUWI6YuDEpx4IZ36QYD8/JhVI//1cyScvNE\nhVCZKVbNAgMBAAECggEABnYSdt7r4MJzS4AvkqpMFFxfHvFZBTx2CIKZAE+zaw5x\n+4nbaFfxPkgs8CdsJF9FbkB6v0trzuHA5A1Xpl9z7JMPcYBQ6i4iwikLotqn0IDo\nZGF7ZfmDchXHS26pNzsUkKwMuG9blD5kcDLJKwWhH0hXUGYvRfDnnl86CcEyrU1r\n0HNeDfxt59u8Pemj5FjpLmpclB8lWxyUKwpgrYPvjOQsiSMezJ7sh9Fa00b43TJ7\nnSkbkCuP9cZFnHQh/3Wwzm/63f1ykTr7VwcsCe+yuobj6D1ZJ0rzi8j5z6aD9Xh9\n66oB0rkc6u3tTw1zI5nrVNG5XBXli9JXXzTQtL4soQKBgQDhdqMumRZmwo1kikfb\n7A1W1OnXKCheFLE7PT72Wxj+5/56oqyi1ylDkzSOYu9FTY30IIr4YBv7BkvnBo4y\nqDpx+iX9fW14K1S9IIW8Eqx7xDV2YrWTHwEXUWJrLx2UP/ufAl8KQTK/zznCh1H5\nAOgXanloIoN27oSpotP6u9C3GQKBgQC7ZdsxgRrgDrkfbcvZy0LWx/Z9EhUlEJxY\nrlSGK9mw4tHQ8NtN5j/tGfMC4Qkw74CIjgb+qCJL8PkplunkTZUD1ZqZ/mc1VwBi\nrlpvKQYDahLvA9qi1A4y4Sh47HYKdZ0YzsLlwWK9jT9nWMiWs7dQ3N/tYTQ87Fky\nwsR37vPX1QKBgD/v3dzECwc/GsutLy2dpja+kEW0nKX5Zj0vZCCGuvLmpVLvuNdA\n/vGr2Bac1c+oa54UcHR5BNZN9c5hHIgfDtvtnUJihF20pAYyJ9qqzQEYJjUZTvaW\nrz+Gk8tjhBbbgiaYjI0i6hpc0LtqloNvj2G8jwtJ5lAe2b4lb8nF4y1ZAoGAZHug\nRfIpO/0JDK4uAVF5PHuqUrQQfHhkrTSFBBCdQLjOso+DuEh+/J7ObDvIVuIFdLNb\nUs9K3JeQstlF/vIOtiiiJnKAWtyUy1UcDsDbhZcqIdlaMbctCeErd3Orc75PB09O\nuC2yyVrkpYC4xf4FjKlytPFLNmOxDIPdH0YUoCUCgYEAvrIS/LY35nFqei5ah+aV\nYKbiiBMTyhcgQepLsoc7LAQ5L7mdZRty7ahjpcEMdVFMb6J8zu6vp38X4pRGCJzI\neD46r5VlvZCq3CdYyyeUCaQK4mNW4+cIQ8bev2uOQCcjs4FjU6TH6bm+UxSvXXfQ\nU2Wc/kQGGM6+OxXE/meMjig=\n-----END PRIVATE KEY-----\n",
          "client_email": "didi-auth@appspot.gserviceaccount.com",
          "client_id": "107760438833158151256",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/didi-auth%40appspot.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        },
      ),[firebaseMessagingScope]
    );
    final accessToken=client.credentials.accessToken.data;

    return accessToken;
  }
}
