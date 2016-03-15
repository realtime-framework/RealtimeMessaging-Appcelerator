package ibt.ortc.api;

public interface OnRestWebserviceResponse {
	/** 
	 * @param Request error exception
	 * @param Request result body
	 */
	public void run(Exception error,String response);
}
