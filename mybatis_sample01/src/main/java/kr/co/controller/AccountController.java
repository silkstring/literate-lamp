package kr.co.controller;

import java.sql.SQLException;
import java.util.List;

import kr.co.dao.AccountDAO;
import kr.co.view.AccountView;
import kr.co.vo.AccountVO;

public class AccountController {

	public void getAccountRequestList() {
		AccountDAO dao = new AccountDAO();
		AccountView view = new AccountView();

		List<AccountVO> data = dao.selectReqAccount();
		view.show(data);
	}

	public void setAccountRequest(String nickname, String email) {
		AccountDAO dao = new AccountDAO();
		AccountView view = new AccountView();

		AccountVO account = new AccountVO();
		account.setNickname(nickname);
		account.setEmail(email);
		
		boolean result;
		try {
			result = dao.insertReqAccount(account);
			view.show(result);
		} catch (Throwable e) {
			String reason = e.getMessage().split(":")[0];
			if (reason.equals("ORA-00001")) {
				System.out.println("닉네임 또는 이메일 주소가 중복되었습니다. 다시 입력하세요.");
			}
		}

	}

}
