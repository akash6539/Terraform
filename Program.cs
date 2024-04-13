var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();
var hostName = System.Net.Dns.GetHostName();
var appVersion = "1.0";

app.MapGet("/", () => $"{hostName} version:{appVersion}");

app.Run();
