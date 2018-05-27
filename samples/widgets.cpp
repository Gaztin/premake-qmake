#include <QtWidgets/QApplication>
#include <QtWidgets/QMainWindow>

int main(int argc, char* argv[])
{
	QApplication app(argc, argv);
	QMainWindow  w;

	w.show();

	return app.exec();
}
