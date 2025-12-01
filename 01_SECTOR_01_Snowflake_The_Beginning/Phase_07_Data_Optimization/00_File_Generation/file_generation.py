import csv

for i in range(1, 101):
    filename = f"file_{i:03}.csv"
    with open(filename, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["id", "date", "amount", "region"])

        for j in range(1, 101):
            writer.writerow([j, "2025-01-01", 100 + j, "South"])
