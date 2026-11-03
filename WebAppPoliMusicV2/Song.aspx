<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Song.aspx.cs" Inherits="WebAppPoliMusicV2.Song" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>PoliMusic - Song List</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <style type="text/css">
        :root {
            --bg: #0F172A;
            --panel: #1E293B;
            --panel-2: #273449;
            --line: #334155;
            --text: #E2E8F0;
            --muted: #94A3B8;
            --accent: #F59E0B;
            --accent-2: #38BDF8;
            --danger: #F87171;
        }
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: 'Poppins', Segoe UI, Arial, sans-serif;
            background: radial-gradient(circle at top right, #1E3A5F 0%, var(--bg) 55%);
            color: var(--text);
            min-height: 100vh;
        }
        .topbar {
            display: flex; align-items: center; justify-content: space-between;
            padding: 16px 40px; background: rgba(15, 23, 42, .85);
            border-bottom: 1px solid var(--line);
        }
        .brand { font-size: 24px; font-weight: 700; letter-spacing: .5px; }
        .brand span { color: var(--accent); }
        .user-box { display: flex; align-items: center; gap: 14px; }
        .user-box img {
            width: 46px; height: 46px; border-radius: 50%;
            object-fit: cover; border: 2px solid var(--accent);
        }
        .welcome { line-height: 1.3; }
        .welcome b { color: var(--accent); }
        .role {
            display: inline-block; margin-top: 2px; padding: 1px 10px;
            font-size: 11px; font-weight: 600; text-transform: uppercase;
            border-radius: 20px; background: rgba(56, 189, 248, .15); color: var(--accent-2);
        }
        .btn-logout {
            padding: 8px 18px; border-radius: 22px; border: 1px solid var(--accent);
            color: var(--accent); text-decoration: none; font-weight: 600; transition: .2s;
        }
        .btn-logout:hover { background: var(--accent); color: var(--bg); }
        .container { max-width: 1150px; margin: 36px auto; padding: 0 24px; }
        .hero {
            display: flex; justify-content: space-between; align-items: flex-end; flex-wrap: wrap; gap: 16px;
            padding: 28px 32px; border-radius: 18px;
            background: linear-gradient(135deg, #1E293B 0%, #2B2F55 100%);
            border: 1px solid var(--line);
        }
        .hero small { color: var(--accent-2); font-weight: 600; letter-spacing: 2px; text-transform: uppercase; }
        .hero h1 { margin: 6px 0 4px; font-size: 42px; }
        .hero p { margin: 0; color: var(--muted); }
        .stats { display: flex; gap: 12px; }
        .stat {
            min-width: 120px; padding: 12px 18px; border-radius: 14px;
            background: rgba(15, 23, 42, .6); text-align: center;
        }
        .stat b { display: block; font-size: 26px; color: var(--accent); }
        .stat span { font-size: 12px; color: var(--muted); }
        .card {
            margin-top: 26px; padding: 8px 8px 16px; border-radius: 18px;
            background: var(--panel); border: 1px solid var(--line); overflow-x: auto;
        }
        .song-table { width: 100%; border-collapse: collapse; }
        .song-table th {
            padding: 16px 14px; text-align: left; font-size: 12px; letter-spacing: 1px;
            text-transform: uppercase; color: var(--muted); border-bottom: 2px solid var(--accent);
        }
        .song-table td { padding: 14px; border-bottom: 1px solid var(--line); vertical-align: middle; }
        .song-table tr:hover td { background: var(--panel-2); }
        .song-table tr.playing td { background: rgba(245, 158, 11, .12); }
        .song-table tr.playing .song-name { color: var(--accent); }
        .song-name { font-weight: 600; }
        .plays { text-align: center; }
        audio { width: 250px; height: 36px; }
        .missing { display: none; margin-top: 4px; font-size: 12px; color: var(--danger); }
        .unavailable .missing { display: block; }
        .message { color: var(--danger); font-weight: 600; }
        .footer { margin: 30px 0; text-align: center; color: var(--muted); font-size: 13px; }
        @media (max-width: 700px) {
            .topbar { flex-direction: column; gap: 12px; padding: 16px; }
            .hero h1 { font-size: 32px; }
        }
    </style>
</head>
<body>
    <form id="formSong" runat="server">
        <header class="topbar">
            <div class="brand">&#9835; Poli<span>Music</span></div>
            <div class="user-box">
                <asp:Image ID="imgUser" runat="server" AlternateText="Foto de usuario" />
                <div class="welcome">
                    Bienvenido, <b><asp:Label ID="lblUserName" runat="server" /></b><br />
                    <asp:Label ID="lblRole" runat="server" CssClass="role" />
                </div>
                <asp:HyperLink ID="lnkLogout" runat="server" NavigateUrl="~/Logout.aspx" CssClass="btn-logout">Cerrar sesión</asp:HyperLink>
            </div>
        </header>

        <main class="container">
            <section class="hero">
                <div>
                    <small>Catálogo PoliMusic</small>
                    <h1>Song List</h1>
                    <p>A continuación se presenta el listado de canciones disponibles para reproducir.</p>
                </div>
                <div class="stats">
                    <div class="stat"><b><asp:Label ID="lblCount" runat="server" Text="0" /></b><span>canciones</span></div>
                    <div class="stat"><b><asp:Label ID="lblPlays" runat="server" Text="0" /></b><span>reproducciones</span></div>
                </div>
            </section>

            <asp:Label ID="lblMessage" runat="server" CssClass="message" />

            <section class="card">
                <asp:GridView ID="gvSongs" runat="server" AutoGenerateColumns="False" CssClass="song-table"
                    GridLines="None" EmptyDataText="No hay canciones registradas.">
                    <Columns>
                        <asp:BoundField DataField="ID_SONG" HeaderText="N°" />
                        <asp:TemplateField HeaderText="Canción">
                            <ItemTemplate>
                                <span class="song-name"><%# Server.HtmlEncode(Convert.ToString(Eval("SONG_NAME"))) %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="ARTISTS" HeaderText="Artistas" />
                        <asp:BoundField DataField="ALBUMS" HeaderText="Álbumes" />
                        <asp:BoundField DataField="PLAYS" HeaderText="Reproducciones" ItemStyle-CssClass="plays" HeaderStyle-CssClass="plays" />
                        <asp:TemplateField HeaderText="Reproductor">
                            <ItemTemplate>
                                <audio controls="controls" preload="metadata" src='<%# GetSongUrl(Eval("SONG_PATH")) %>'></audio>
                                <span class="missing">&#9679; Archivo no disponible</span>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </section>

            <div class="footer">PoliMusic &middot; Aplicación web monolítica en ASP.NET Framework 2.0 &middot; Mateo Calvache</div>
        </main>
    </form>

    <script type="text/javascript">
        // Reproductor: una sola canción a la vez, resalta la fila activa
        // y marca las canciones cuyo archivo mp3 no existe en el servidor.
        document.addEventListener('DOMContentLoaded', function () {
            var players = document.querySelectorAll('.song-table audio');

            function markUnavailable(audio) {
                audio.parentNode.className += ' unavailable';
            }

            for (var i = 0; i < players.length; i++) {
                (function (audio) {
                    var row = audio.parentNode.parentNode;

                    audio.addEventListener('play', function () {
                        for (var j = 0; j < players.length; j++) {
                            if (players[j] !== audio) { players[j].pause(); }
                        }
                        var rows = document.querySelectorAll('.song-table tr.playing');
                        for (var k = 0; k < rows.length; k++) { rows[k].className = ''; }
                        row.className = 'playing';
                    });

                    audio.addEventListener('pause', function () { row.className = ''; });
                    audio.addEventListener('ended', function () { row.className = ''; });
                    audio.addEventListener('error', function () { markUnavailable(audio); });

                    // Si el error ocurrió antes de registrar el evento
                    if (audio.error || !audio.getAttribute('src')) { markUnavailable(audio); }
                })(players[i]);
            }
        });
    </script>
</body>
</html>