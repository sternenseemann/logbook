let template = "<!doctype html>
<html>
<head>
  <meta charset=\"utf-8\">
  <title>log</title>
</head>
<body>
  <main>
    <h1>log</h1>
    {% for entry in entries %}
    <article id=\"{{ entry.date }}\">
      <h2>{{ entry.date }}</h2>
      {% autoescape false %}
      {{ entry.summary }}
      <ul>
      {% for item in entry.items %}
        <li>
          {{ item.title }}
          {{ item.text }}
        </li>
      {% endfor %}
      {% endautoescape %}
      </ul>
    </article>
    {% endfor %}
  </main>
</body>"
