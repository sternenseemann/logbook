let template = "<!doctype html>
<html>
<head>
  <meta charset=\"utf-8\">
  <title>{{ title }}</title>
</head>
<body>
  <main>
    {% for entry in entries %}<article id=\"{{ entry.date }}\">
      <h2>{{ entry.date }}</h2>
      {% autoescape false %}{{ entry.summary }}
      <ul>{% for item in entry.items %}
        <li>
          <div>
            {{ item.title }}
          </div>
          <div>
            {{ item.text }}
          </div>
        </li>{% endfor %}{% endautoescape %}
      </ul>
    </article>{% endfor %}
  </main>
</body>"
