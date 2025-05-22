from faker import Faker
import random
import datetime

fake = Faker()
domains = ["example.com", "test.org", "sample.net", "site.info", "web.io"]

def generate_webpage(index):
    domain = random.choice(domains)
    path = f"/page{index}"
    url = f"http://{domain}{path}"
    html_content = fake.text(max_nb_chars=random.choice([500, 1500, 5000]))
    title = fake.sentence(nb_words=5)
    status_code = random.choice([200, 404, 500])
    timestamp = fake.date_time_between(start_date='-120d', end_date='now')
    outlinks = [f"http://{random.choice(domains)}/page{random.randint(1, 20)}" for _ in range(random.randint(0, 5))]

    return {
        "row_key": url,
        "content": html_content,
        "metadata": {
            "title": title,
            "status": status_code,
            "created_at": timestamp.strftime('%Y-%m-%d %H:%M:%S'),
            "size": len(html_content)
        },
        "outlinks": outlinks
    }

# Example: Print HBase put commands
for i in range(1, 21):
    page = generate_webpage(i)
    print(f"put 'webtable', '{page['row_key']}', 'content:html', '{page['content']}'")
    for k, v in page['metadata'].items():
        print(f"put 'webtable', '{page['row_key']}', 'metadata:{k}', '{v}'")
    for j, link in enumerate(page['outlinks']):
        print(f"put 'webtable', '{page['row_key']}', 'outlinks:link{j}', '{link}'")
