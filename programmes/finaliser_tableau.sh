#!/bin/bash

# Fermer le tableau HTML
cat >> "tableaux/ar.html" << EOF
                </tbody>
            </table>
            
            <div class="notification is-success">
                <p><strong>إحصائيات:</strong></p>
                <p>تم تحليل 60 رابطاً (30 لكل رسم)</p>
            </div>
        </div>
    </section>
    
    <footer class="footer">
        <div class="content has-text-centered">
            <p>مشروع تحليل كلمة "الروح" - Projet PPE 2024-2025</p>
        </div>
    </footer>
</body>
</html>
EOF

echo "✓ Tableau ar.html finalisé !"
