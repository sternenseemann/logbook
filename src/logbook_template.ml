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
    <article>
      <h2>{{ entry.date }}</h2>
      <p>{{ entry.summary }}</p>
      <ul>
      {% for item in entry.items %}
        <li>
          <p><em>{{ item.title }}</em></p>
          <p>{{ item.text }}</p>
        </li>
      {% endfor %}
      </ul>
    </article>
    {% endfor %}
  </main>
</body>"
