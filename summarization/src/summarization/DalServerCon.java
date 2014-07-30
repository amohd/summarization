package summarization;

import java.io.DataInputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.net.Socket;
import java.net.UnknownHostException;

public class DalServerCon {

	Socket clientSocket = null;
	// The output stream
	PrintStream os = null;
	// The input stream
	DataInputStream is = null;
	// The default port.
	int portNumber = 2222;
	// The default host.
	String host = "localhost";

	public Socket getClientSocket() {
		return clientSocket;
	}

	public void setClientSocket(Socket clientSocket) {
		this.clientSocket = clientSocket;
	}

	public PrintStream getOs() {
		return os;
	}

	public void setOs(PrintStream os) {
		this.os = os;
	}

	public DataInputStream getIs() {
		return is;
	}

	public void setIs(DataInputStream is) {
		this.is = is;
	}

	public int getPortNumber() {
		return portNumber;
	}

	public void setPortNumber(int portNumber) {
		this.portNumber = portNumber;
	}

	public String getHost() {
		return host;
	}

	public void setHost(String host) {
		this.host = host;
	}

	public DalServerCon(int portNumber, String host) {
		super();
		this.portNumber = portNumber;
		this.host = host;
	}

	public boolean connect() throws UnknownHostException, IOException {
		boolean result = false;

		clientSocket = new Socket(host, portNumber);

		os = new PrintStream(clientSocket.getOutputStream());
		is = new DataInputStream(clientSocket.getInputStream());
		result = true;
		return result;
	}

	public void close() throws IOException {
		if (this.os != null)
			os.close();
		if (this.is != null)
			is.close();
		if (this.clientSocket != null)
			this.clientSocket.close();
	}

	public void reset() throws IOException {
		if (this.os != null)
			os.close();
		if (this.is != null)
			is.close();
		if (this.clientSocket != null) {
			if (!this.clientSocket.isClosed()) {
				this.clientSocket.shutdownInput();
				this.clientSocket.shutdownOutput();
				this.clientSocket.close();
			}
		}
		this.connect();

	}

}
